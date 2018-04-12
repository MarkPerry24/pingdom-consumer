Function New-PingdomAuthToken
{
    <#
        .SYNOPSIS
        Auth token is required for all pingdom actions

        .PARAMETER Credential
            Required to authenticate to pingdom as user

        .PARAMETER AppKey
            Required for group accounts and is the Application Key registered in Pingdom.

        .PARAMETER AccountEmail
            Requied for group accounts and is the email of the primary account in a team subscription.

        .EXAMPLE
            PS C:\>$userCredential = [pscredential]::new("PingdomUserName", $secureString)
            PS C:\>New-PingdomAuthToken $userCredential
            
            Will Create an auth token for interaction with Pingdom API
            
        .EXAMPLE
            $secureString = "myInsecurePwd" | ConvertTo-Securestring -AsPlainText -Force
            PS C:\>$pingdomUserCredential = [pscredential]::new("PingdomUserName", $secureString)
            PS C:\>New-PingdomAuthToken $pingdomUserCredential
            
            Will Create an auth token
            
        .EXAMPLE
            New-PingdomAuthToken MyPingdomAccountName
            
            Will prompt for password and Create an auth token with 'MyPingdomAccountName' as the username 

        .EXAMPLE
            New-PingdomAuthToken -Credential (Get-Credential) -AppKey "example2app2key" -AccountEmail "bob.bobling@example.com"

            Creates a token with credentials to connect to pingdom api, sets the AppKey and Account Email options.

    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory)]
        [string]
        $AppKey,

        [Parameter(Mandatory)]
        [string]
        $AccountEmail
    )

    New-Variable -Name authToken -Value (
            [PingdomAuthToken]::new(
                $Credential,
                $AppKey,
                $AccountEmail
            )
        ) -Description "Pingdom API Helper" -Option ReadOnly -Visibility Private -Scope Script -Force
}