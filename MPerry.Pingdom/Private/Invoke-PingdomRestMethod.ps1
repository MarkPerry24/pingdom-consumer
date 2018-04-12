Function Invoke-PingdomRestMethod
{
    [CmdletBinding()]
    Param
    (
        [string]
        [Parameter(Mandatory)]
        $Method,

        [string]
        [Parameter(Mandatory)]
        $Uri,
        
        [hashtable]
        $Body
    )

    Begin
    {
        Test-PingdomAuthToken
    }

    Process
    {
        $params = @{
            Method = $Method 
            Headers = $authToken.Headers
            Credential = $authToken.Credential
            Uri = "$($authToken.baseUri)$Uri"
            Body = $Body
        }

        try 
        {
            $response = Invoke-RestMethod @params -ErrorVariable pev
            $response
        }
        catch
        {
            $msg = ConvertFrom-Json $pev.Message

            switch ($msg.Error.statuscode)
            {
                401 { Write-Error "Credentials are not correct" -ErrorAction Stop }
                403 { Write-Error $msg.Error.errormessage -ErrorAction Stop }
                default { Write-Error $msg.Error.errormessage -ErrorAction Stop }
            }
        }
    }
}

