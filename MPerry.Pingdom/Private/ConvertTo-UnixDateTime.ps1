Function ConvertTo-UnixDateTime
{
    [CmdletBinding()]
    param
    (
        [DateTime]
        $DateTime
    )

    [uint32]$DateTime.Subtract([DateTime]::new("1970","1","1")).TotalSeconds
}