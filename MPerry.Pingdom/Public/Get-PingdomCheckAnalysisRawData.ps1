Function Get-PingdomCheckAnalysisRawData
{
     <#

    .SYNOPSIS
        Retrieves the detailed analysis data of a check (Pingdom do not thoroughly document this)

    .DESCRIPTION  
        As this function needs a check id and an analysis Id it's most useful when combined with Get-PingdomCheckAnalysis

    .EXAMPLE
        PS C:\> $analysisData = Get-PingdomHChecks | ?{$_.name -match "bob"} | Get-PingdomAnalysis | Select -First 1 | Get-PingdomCheckAnalysisRawData
        
        Finds all checks with "bob" in the name and retrieves the Check Analysis entries, 
        selects the first (usually most recent) analysis entry and then retrieves the Detailed analysis, 
        saving the result into the variable $analysisData.
    #>

    [CmdletBinding()]
    Param 
    (
        [int32[]]
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        $CheckId,

        [int32[]]
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        $AnalysisId,

        [switch]
        $Raw
    )

    Begin
    {
        Test-PingdomAuthToken
        Function Convert-UnixTimeToUTC
        {
            param
            (
                [ref]
                $pingdomRawAnalysis
            )

            $pingdomRawAnalysis.Value.analysisresult.time_triggered = ConvertFrom-UnixDateTime $pingdomRawAnalysis.Value.analysisresult.time_triggered

            for ($i = 0; $i -lt $pingdomRawAnalysis.Value.analysisresult.tasks.count; $i++)
            {
                $pingdomRawAnalysis.Value.analysisresult.tasks[$i].time_start = ConvertFrom-UnixDateTime $pingdomRawAnalysis.Value.analysisresult.tasks[$i].time_start
                $pingdomRawAnalysis.Value.analysisresult.tasks[$i].time_end = ConvertFrom-UnixDateTime $pingdomRawAnalysis.Value.analysisresult.tasks[$i].time_end

                if ($pingdomRawAnalysis.Value.analysisresult.tasks[$i].result.timestamp)
                {
                    $pingdomRawAnalysis.Value.analysisresult.tasks[$i].result.timestamp = ConvertFrom-UnixDateTime $pingdomRawAnalysis.Value.analysisresult.tasks[$i].result.timestamp
                }
            }
        }
    }

    Process
    {
        $invokeParameters = @{
            Method      = "GET"
            Uri = "analysis/$CheckId/$AnalysisId"
        }

        $response = Invoke-PingdomRestMethod @invokeParameters

        # correcting output as some bits in array which should be pscustomobjects
        for ($i = 0; $i -lt $response.analysisresult.tasks.count; $i++)
        {
            $result = @{}
            foreach ($r in $response.analysisresult.tasks[$i].result)
            {
                $result += @{ $r.name = $r.value }
            }
            
            $newResult = [PSCustomObject]$result
            [string[]]$DefaultProperties = "resolve_status" ,"hostname", "traceroute_time", "resolve_time", "response_time", "timestamp", "ip"
            $ddps = [System.Management.Automation.PSPropertySet]::new("DefaultDisplayPropertySet",$DefaultProperties)
            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]$ddps 

            # Attach default display property set
            $newResult | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers
            
            $response.analysisresult.tasks[$i].result = $newResult
        }

        if (-not($Raw.IsPresent))
        {
            Convert-UnixTimeToUTC ([ref]$response)   
        }
        
        $response
    }
}