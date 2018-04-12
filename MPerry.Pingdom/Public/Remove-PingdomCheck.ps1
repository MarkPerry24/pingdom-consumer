Function Remove-PingdomCheck
{
     <#

    .SYNOPSIS

    Function for deleting checks in Pingdom:  https://my.pingdom.com/newchecks/checks#

    .DESCRIPTION

        Grants the ability to delete checks.

    .PARAMETER -Id

        An Id for a check must be specified.  Can use Get-pingdomChecks to find the Id

    .EXAMPLE
        Remove-PingdomCheck -Id 123456
        Resume the check 123456.

    .EXAMPLE
        Remove-PingdomCheck -Id 123456, 234567
        Removes the checks 123456 & 234567

    .EXAMPLE
        $PingCred = [PSCredential]::new(<username>, $("plain_password" | ConvertTo-SecureString -AsPlainText -Force))
        $Authtoken = New-PingdomAuthToken -Credential $PingCred
        Get-PingdomChecks | ?{$_.Name -match "bob"} | Remove-PingdomCheck
  
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact="High")]
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
        foreach ($item in $Id)
        {
            $name = ""
            if ($WhatIfPreference.IsPresent)
            {
                $name = (Get-PingdomCheck -id $Id).Name
            }

            if ($PSCmdlet.ShouldProcess("Deleting check $name ($Id)"))
            {
                $invokeParameters = @{
                    Method = "DELETE"  # We are deleting a check
                    Uri = "checks/$item"
                }
                
                $delete = Invoke-PingdomRestMethod @invokeParameters
                Write-Verbose $delete.message
            }
            else
            {
                Write-Verbose "Confirm was false!!"
            }
        }
    }    
}