Function Get-PingdomCheck
{
     <#

    .SYNOPSIS

    Function for retrieving specific check properties in Pingdom:  https://my.pingdom.com/newchecks/checks#

    .DESCRIPTION

    Shows check advanced properties:  https://www.pingdom.com/resources/api/2.1

    .EXAMPLE
        $Authtoken = New-PingdomAuthToken [pscredential]::new("username", "securestring")
        PS C:\>Get-PingdomCheck -authToken $Authtoken -id 123456

        Gets advanced properties of check

    .EXAMPLE
        $Authtoken = New-PingdomAuthToken [pscredential]::new("username", "securestring")
        PS C:\>Get-PingdomHChecks -authToken $Authtoken | ?{$_.name -match "bob"} | Get-PingdomCheck -authToken $Authtoken
        
        Finds all checks with bob in the name and retrieve the advanced properties
    #>

    [CmdletBinding()]
    Param 
    (
        [int32[]]
        [parameter(
            Mandatory, 
            ValueFromPipelineByPropertyName,
            HelpMessage = "Requires Pingdom Check Id. Using piped input from Get-PingdomChecks might help here."
        )]
        [Alias("checkid")]
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
            $invokeParameters = @{
                                    Method      = "GET"
                                    Uri = "checks/$item"
                                    Body = @{
                                        include_teams = $true
                                    }
                                }

            $response = Invoke-PingdomRestMethod @invokeParameters
            $response.check
        }
    }
}