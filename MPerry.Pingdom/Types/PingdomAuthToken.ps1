class PingdomAuthToken
{
    [pscredential]
    $Credential

    [hashtable]
    $Headers

    [uri]
    $BaseUri = "https://api.pingdom.com/api/2.1/"
    
    PingdomAuthToken(
        [pscredential]$userCred,
        [string]$AppKey,
        [string]$AccountEmail
    )
    {
        $this.Credential = $userCred
        $this.Headers = @{
            "App-Key" = $AppKey
        }

        if ($AccountEmail)
        {
            $this.Headers."Account-Email" = $AccountEmail
        }
    }
}