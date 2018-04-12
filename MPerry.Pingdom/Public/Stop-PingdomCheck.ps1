Function Stop-PingdomCheck
{
     <#

    .SYNOPSIS

    Function for pausing checks in Pingdom:  https://my.pingdom.com/newchecks/checks#

    .DESCRIPTION

    Grants the ability to pause checks.

    .PARAMETER -Id

    An Id for a check must be specified.  Can use Get-pingdomChecks to find the Id

    .EXAMPLE
        Stop-PingdomCheck -Id 123456
        Pauses the check 123456.

    .EXAMPLE
        Stop-PingdomCheck -Id 123456, 234567
        Pauses the checks 123456 & 234567

    .EXAMPLE
        $PingCred = [PSCredential]::new(<username>, $("plain_password" | ConvertTo-SecureString -AsPlainText -Force))
        Get-PingdomChecks | ?{$_.Name -match "google"} | Stop-PingdomCheck

    #>
    [CmdletBinding()]
    Param
    (
        [string[]]
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        $Id
    )
    
    Begin
    {
        Test-PingdomAuthToken
    } 
    
    Process
    {
        foreach ($item in $Id)
        {
            
            $body = [CheckBaseParams]@{
                paused = $true
            }

            $invokeParameters = @{
                                    Method = "PUT"  # We are stopping a check
                                    Uri = "checks/$Item"
                                    Body = $body.ToHashTable()
                                }

            $response = Invoke-PingdomRestMethod @InvokeParameters
            Write-Verbose $response.message
        }
    }
}