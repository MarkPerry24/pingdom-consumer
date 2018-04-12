Function ConvertFrom-UnixDateTime
{
    [CmdletBinding()]
    param
    (
        [uint32]
        $UnixDateTimeStamp
    )

    [System.DateTimeOffset]::FromUnixTimeSeconds($UnixDateTimeStamp).UtcDateTime
}