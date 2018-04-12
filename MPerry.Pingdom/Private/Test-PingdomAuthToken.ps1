Function Test-PingdomAuthToken
{
    if (-not $authToken)
    {
        Write-Error "Please run 'New-PingdomAuthToken' first" -ErrorAction Stop
    }
}