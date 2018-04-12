Function Get-PingdomCheckType
{
    param
    (
        [string]
        $type
    )

    $pchecktype = switch ($type)
    {
        "http" { [CheckHTTPParams]@{}; break }
        "httpcustom" { [CheckHTTPCustomParams]@{}; break }
        "tcp" { [CheckTCPUDPParams]@{}; break }
        "ping" { [CheckPINGParams]@{}; break }
        "dns" { [CheckDNSParams]@{}; break }
        "smtp" { [CheckSMTParams]@{}; break }
        "pop" { [CheckPOPIMAPParams]@{} }
        "imap" { [CheckPOPIMAPParams]@{} }
        default { throw "Invalid type" }
    }

    $pchecktype
}