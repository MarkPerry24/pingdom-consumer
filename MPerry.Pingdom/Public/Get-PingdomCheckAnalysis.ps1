Function Get-PingdomCheckAnalysis
{
     <#

    .SYNOPSIS
        Function for retrieving specific checks analysis (Pingdom do not thouroughly document this)

    .DESCRIPTION
    
    .EXAMPLE
        PS C:\> Get-PingdomCheckAnalysis -id 123456

        Gets analysis entries of specific check

    .EXAMPLE
        PS C:\> Get-PingdomChecks | ?{ $_.name -match "Test" } | Get-PingdomCheckAnalysis
        
        Finds all checks with "Test" in the name and retrieve the Check Analysis entries
    #>

    [CmdletBinding()]
    Param 
    (
        [int32[]]
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias("CheckId")]
        $Id,

        [switch]
        $Raw
    )

    Begin
    {
        Test-PingdomAuthToken
    }

    Process
    {
        foreach ($item in $Id)
        {
            $invokeParameters = @{
                Method = "GET"
                Uri = "analysis/$item"
            }

            $response = Invoke-PingdomRestMethod @invokeParameters
            
            if ($Raw.IsPresent)
            {
                $response
            }
            else
            {
                foreach ($item in $response.analysis)
                {
                    [psCustomObject]@{
                        CheckId = $Id
                        AnalysisId = $item.id
                        timefirsttest = ConvertFrom-UnixDateTime -UnixDateTimeStamp $item.timefirsttest
                        timeconfirmtest = ConvertFrom-UnixDateTime -UnixDateTimeStamp $item.timeconfirmtest
                    }
                }
            }
        }
    }
}