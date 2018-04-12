Function Get-PingdomAlerts
{
     <#

    .SYNOPSIS
        Retrieve Pingdom alerts generated based upon given critera.

    .DESCRIPTION
        This Function returns alerts which were generated based upon the criteria which is defined.  The default will return the newest 100 records of all
        checks.  The real power comes from being able to pipe check ids from Get-PindomChecks or Get-PingdomChecks.  However you'd want to combine with
        another filter e.g. Get-PingdomChecks | Where-Object Name -match "bob" | Get-PingdomAlerts
        You can also do the reverse and pipe from Get-PingdomAlerts to Get-PingdomCheck but you need to be a little more careful as you can end up with lots of checks exactly the same.

    .PARAMETER Limit
        The default Limit is set to 100 which matches the Pingdom API default.  The number you select will be rounded up to nearest 100 e.g. 
        101 may return 200 records.  The limiting factor being the actual number of alerts may be 103 in which case 200 records will be requested in
        batches of 100 and the second batch will have 3 records.  You can see this using the -Verbose switch.

    .PARAMETER From
       Limit the records by FROM date.  You can use the date format according to your regional settings e.g dd/mm/yyyy in UK, mm/dd/yyyy in US.
       This will be converted to Unix Format with epoch starting from 01/01/1970 as per Pingdom Requirements.

    .PARAMETER To
       Limit the records by TO date.  You can use the date format according to your regional settings e.g dd/mm/yyyy in UK, mm/dd/yyyy in US.
       This will be converted to Unix Format with epoch starting from 01/01/1970 as per Pingdom Requirements.

    .PARAMETER Id
       Limit the records returned by Check Ids this parameter accepts pipeline input which means you can pipe from Get-PingdomChecks or Get-PingdomCheck.
       This is probably the most useful parameter for general usage when looking at alerts. 

    .PARAMETER UserIds
        Limit the alerts returned to only include those to a specific user.  There is a helper which will give tab completion of a single entry but is most 
        useful in powershell_ise as in powershell will only give the ids available whilst ise will show names and emails accociated.  The parameter accepts
        an array and so tab compeletion will work for comma seperated values but even in ise you lose the extra info you benefit from on the first one.  
        If you would like more control you can use Get-PingdomUsers function to return users and filter as required.  
        e.g. Get-PingdomAlerts -UserIds ((Get-PingdomUsers | ? Name -like "*bob*" | Select -ExpandProperty Id) -join ",")
        Will return 100 records sent to any user with bob in their name.

    .PARAMETER Status
        Limit the returned alerts by alert status which include:  pending, sent, delivered, error, not_delivered, no_credits

    .PARAMETER Via
        Limit the returned alerts by medium used to send the alert which include: email, sms, twitter, iphone, android

    .EXAMPLE
        Get-PingdomAlerts
        Will return the most recent 100 alerts

    .EXAMPLE
        Get-PingdomAlerts -Limit 1000
        Will return the most recent 1000 alerts in batches of 100 as per Pingom API requirements

    .EXAMPLE
        Get-PingdomAlerts -Limit 2 | Get-PingdomCheck
        Will return the checks from 2 most recent alerts

    .EXAMPLE
        $alerts = Get-PingdomChecks | ? Name -match bob | Get-PingdomAlerts -Limit 5000 -Verbose
        Will return up to 5000 records of Pingdom Checks with bob in their name and return verbose output and save to variable "alerts"
        
    .EXAMPLE
        Get-PingdomAlerts -Limit 50 -Via email -UserIds 14096206 -Status error
        Will return up to 50 alerts sent by email to the user 14096206 and resulted in an error.  You need to be a bit careful when 
        using multiple filters as they all apply and can often return no alerts at all.
        
    #>
    
    [CmdletBinding()]
    Param 
    (
        [ValidateRange(1,65000)]
        [uint16]
        $Limit = 100,

        [ValidateScript({
            if (Get-Date $_){$true}
        })]
        [object]
        $From,

        [ValidateScript({
            if (Get-Date $_){$true}
        })]
        [object]
        $To,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("CheckIds")]
        [string[]]
        $Id,

        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                Get-PingdomUsers |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.id, $_.name, 'ParameterValue', ("{0}({1})" -f $_.email[0].address, $_.id))
                }
        })]
        [string[]]
        $UserIds,

        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                "pending", "sent", "delivered", "error", "not_delivered", "no_credits" |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "Status")
                }
        })]
        [ValidateScript({
            foreach ($entry in $_)
            {
                $entry -in "pending", "sent", "delivered", "error", "not_delivered", "no_credits"
            }
        })]
        [string[]]
        $Status,

        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                "email", "sms", "twitter", "iphone", "android" |
                ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "Via")
                }
        })]
        [ValidateScript({
            foreach ($entry in $_)
            {
                $entry -in "email", "sms", "twitter", "iphone", "android"
            }
        })]
        [string[]]
        $Via

    )

    Begin
    {
        try
        {
            if ($From)
            {
                [uint32]$uFrom = ConvertTo-UnixDateTime (Get-Date $From)
            }

            if ($To)
            {
                [uint32]$uTo =  ConvertTo-UnixDateTime (Get-Date $To)
            }
        }
        catch
        {
            throw $_
        }

        Test-PingdomAuthToken
        $alerts = @()
        
        $alertBatch = $Limit
        if ($Limit -gt 100)
        {
            # Pingdom API says 300 is max and default is 100 but 100 is the max
            $alertBatch = 100
        }
    }

    Process
    {
        $checks += $Id
        [string]$checkids = $checks -join ","
    }
    
    End
    {
        for ($offset = 0; $alertCount -lt $Limit; $offset += 100)
        {
            $invokeParameters = @{
                                    Method = "GET"
                                    Uri = "actions"
                                    Body = @{
                                       limit = $alertBatch
                                       offset = $offset
                                    }
                                }

            if ($uFrom){ $invokeParameters.Body.from = $uFrom }
            if ($uTo){ $invokeParameters.Body.to = $uTo }
            if ($checkids){ $invokeParameters.Body.checkids = $checkids }
            if ($UserIds){ $invokeParameters.Body.userids = $UserIds -join "," }
            if ($Status){ $invokeParameters.Body.status = $Status -join "," }
            if ($Via){ $invokeParameters.Body.via = $Via -join ","}

            $response = Invoke-PingdomRestMethod @invokeParameters
            foreach ($alert in $response.actions.alerts)
            {
                if ((-not $alerts[-1].time) -or 
                    $alert.time -le $alerts[-1].time
                    )
                {
                    $alerts += $alert | Add-Member -MemberType NoteProperty -Name datetime -Value (ConvertFrom-UnixDateTime $alert.time) -PassThru
                }
            }

            if ($response.actions.alerts.count -lt $alertBatch)
            {
                Write-Verbose "There are no more alerts from Server"
                $alertCount = $Limit
            }
            else
            {
                $alertCount += $response.actions.alerts.count 
            }
        }

        $alerts
    } 
}
