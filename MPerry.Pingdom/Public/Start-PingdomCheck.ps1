Function Start-PingdomCheck
{
     <#

    .SYNOPSIS

    Function for resuming checks in Pingdom:  https://my.pingdom.com/newchecks/checks#

    .DESCRIPTION

    Grants the ability to resume checks.

    .PARAMETER -IdOfCheck

    An Id for a check must be specified.  Can use Get-pingdomChecks to find the Id

    .EXAMPLE
        Start-PingdomCheck -Id 123456
        Resume the check 123456.

    .EXAMPLE
        Start-PingdomCheck -Id 123456, 234567
        Resumes the checks 123456 & 234567

    .EXAMPLE
        $PingCred = [PSCredential]::new(<username>, $("plain_password" | ConvertTo-SecureString -AsPlainText -Force))
        New-PingdomAuthToken $PingCred
        Get-PingdomChecks | ?{$_.Name -match "google"} | Start-PingdomCheck

    #>
    [CmdletBinding()]
    Param
    (
        [string[]]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        $Id
        
    ) 

    Begin
    {
        Test-PingdomAuthToken
    }

    Process
    {
        foreach ($Item in $Id)
        {
            
            $body
            $body = [CheckBaseParams]@{
                paused = $false
            }

            $invokeParameters = @{
                                    Method = "PUT"  # We are modifying a check
                                    Uri = "checks/$Item"
                                    Body = $body.ToHashTable()
                                }

            $response = Invoke-PingdomRestMethod @invokeParameters
            Write-Verbose $response.message
        }
    }
}