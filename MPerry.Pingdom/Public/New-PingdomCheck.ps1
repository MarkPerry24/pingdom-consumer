Function New-PingdomCheck
{
    <#

        .SYNOPSIS
        Function for creating checks in Pingdom:  https://my.pingdom.com/newchecks/checks#

        .DESCRIPTION

        Grants the ability to Create Pingdom Checks

        .EXAMPLE
        New-PingdomAuthToken -UserCredentialPingdom [pscredential]$pingcred | New-PingdomCheck -NameOfCheck bob -Host www.google.co.uk

        Creates a default HTTP Check
        
        .EXAMPLE
        Get-PingdomAuthToken -UserCredentialPingdom [pscredential]$pingcred | New-PingdomCheck -NameOfCheck bob -Host www.google.co.uk -DefaultCheckOverrides $(Set-PingdomGeneralCheckParameterDefaultOverrides -NotPaused)

        Creates an HTTP Check with paused parameter overridden to create in an unpaused state

        .EXAMPLE
        $authtoken = New-PingdomAuthToken [pscredential]::new("username", "securestring")
        PS C:\>$authToken | New-PingdomCheck -nameOfCheck bob -host www.google.co.uk | Start-PingdomCheck

        Creates a new HTTP Check and immediately starts the check

    #>
    
    [Cmdletbinding(DefaultParameterSetName="Default", SupportsShouldProcess)]
    Param
    (
        [parameter(ParameterSetName = "HTTPCheck_1", Mandatory)]
        [switch]
        $HTTP,

        [parameter(ParameterSetName = "HTTPCustomCheck_1", Mandatory)]
        [switch]
        $HTTPCustom,

        [parameter(ParameterSetName = "TCPCheck_1", Mandatory)]
        [switch]
        $TCP,

        [parameter(ParameterSetName = "UDPCheck_1", Mandatory)]
        [switch]
        $UDP,

        [parameter(ParameterSetName = "PingCheck_1", Mandatory)]
        [switch]
        $PING,

        [parameter(ParameterSetName = "DNSCheck_1", Mandatory)]
        [switch]
        $DNS,

        [parameter(ParameterSetName = "SMTPCheck_1", Mandatory)]
        [switch]
        $SMTP,

        [parameter(ParameterSetName = "POP3Check_1", Mandatory)]
        [switch]
        $POP3,

        [parameter(ParameterSetName = "IMAPCheck_1", Mandatory)]
        [switch]
        $IMAP,

        [parameter(Mandatory, Position = 1)]
        [string]
        $Name,

        [parameter(Mandatory, Position = 2)]
        [string]
        $Host,

        [parameter(ParameterSetName = "DNSCheck_1", Mandatory)]
        [string]
        $ExpectedIP,

        [parameter(ParameterSetName = "DNSCheck_1", Mandatory)]
        [string]
        $Nameserver,

        [parameter(ParameterSetName = "HTTPCheck_1")]
        [parameter(ParameterSetName = "HTTPCustomCheck_1", Mandatory)]
        [ValidatePattern("^/")]
        [string]
        $Url,

        [parameter(ParameterSetName = "HTTPCustomCheck_1")]
        [ValidateScript({
            [uri]::TryCreate($_, [System.UriKind]::Absolute, [ref]$_)
        })]
        [string[]]
        $AdditionalUrls,

        [parameter(ParameterSetName = "HTTPCheck_1")]
        [parameter(ParameterSetName = "HTTPCustomCheck_1")]
        [parameter(ParameterSetName = "SMTPCheck_1")]
        [Alias("webcredential", "smtpcredential")]
        [pscredential]
        $Auth,

        [parameter(ParameterSetName = "HTTPCheck_1")]
        [parameter(ParameterSetName = "TCPCheck_1", Mandatory)]
        [parameter(ParameterSetName = "UDPCheck_1", Mandatory)]
        [parameter(ParameterSetName = "HTTPCustomCheck_1")]
        [parameter(ParameterSetName = "SMTPCheck_1")]
        [parameter(ParameterSetName = "POP3Check_1", Mandatory)]
        [parameter(ParameterSetName = "IMAPCheck_1", Mandatory)]
        [ValidateRange(1, [uint16]::MaxValue)]
        [uint32]
        $Port,

        [parameter(ParameterSetName = "HTTPCheck_1")]
        [parameter(ParameterSetName = "HTTPCustomCheck_1")]
        [parameter(ParameterSetName = "SMTPCheck_1")]
        [parameter(ParameterSetName = "POP3Check_1", Mandatory)]
        [parameter(ParameterSetName = "IMAPCheck_1", Mandatory)]
        [switch]
        $NoEncryption,

        [parameter(ParameterSetName = "HTTPCheck_1")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ShouldContain,

        [parameter(ParameterSetName = "HTTPCheck_1")]
        [ValidateNotNullOrEmpty()]
        [string]
        $ShouldNotContain,
      
        [parameter(ParameterSetName = "HTTPCheck_1")]
        [ValidateNotNullOrEmpty()]
        [string]
        $PostData,

        [parameter(ParameterSetName = "HTTPCheck_1")]
        [ValidatePattern("^(?:\w|\W)+:(?:\w|\W)+$")]
        [string[]]
        $RequestHeaders,

        [parameter(ParameterSetName = "TCPCheck_1")]
        [parameter(ParameterSetName = "UDPCheck_1", Mandatory)]
        [ValidateNotNullOrempty()]
        [string]
        $StringToSend,

        [parameter(ParameterSetName = "TCPCheck_1")]
        [parameter(ParameterSetName = "UDPCheck_1", Mandatory)]
        [parameter(ParameterSetName = "SMTPCheck_1")]
        [parameter(ParameterSetName = "POP3Check_1", Mandatory)]
        [parameter(ParameterSetName = "IMAPCheck_1", Mandatory)]
        [ValidateNotNullOrempty()]
        [string]
        $StringToExpect,

        [ValidateSet("1", "5", "15", "30", "60")]
        [Alias("Interval")]
        [string]
        $Resolution,

        [ValidateNotNullOrEmpty()]
        [string[]]
        $Tags,

        # NA = North America, EU = Europe, APAC = Asia Pacific, LATAM = Latin America
        [ValidateSet("region:NA", "region:EU", "region:APAC", "region:LATAM")]
        [string[]]
        $Probe_Filters,

        # in milliseconds (ms), Default = 30000 (30 seconds)
        [ValidateRange(1, [int32]::MaxValue)]
        [string]
        $Responsetime_Threshold,

        [ValidateRange(1, [int32]::MaxValue)]
        [string[]]
        $Integrationids,

        [switch]
        $IPv6,

        [ValidateRange([uint32]::MinValue, [int32]::MaxValue)]
        [string[]]
        $UserIds,

        [ValidateRange([uint32]::MinValue, [int32]::MaxValue)]
        [string[]]
        $TeamIds,

        [ValidateRange(0,10)]
        [string[]]
        $SendNotificationWhenDown,

        [ValidateRange(0,60)]
        [string]
        $NotifyAgainEvery,

        [switch]
        $NoNotifyWhenBackUp

    )

    Begin
    {
        Test-PingdomAuthToken
    }

    Process
    {
        $checkDefaults = @{
            paused = $true
            notifywhenbackup = !$NoNotifyWhenBackUp
        }

        if ($HTTP.IsPresent)
        { 
            $checkDefaults.type = "http"
            $body = [CheckHTTPParams]$checkDefaults
            $body.encryption = !$NoEncryption.IsPresent
        }

        if ($SMTP.IsPresent)
        {
            $checkDefaults.type = "smtp"
            $body = [CheckSMTPParams]$checkDefaults
            $body.encryption = !$NoEncryption.IsPresent
        }

        if ($POP3.IsPresent)
        {
            $checkDefaults.type = "pop3"
            $body = [CheckPOPIMAPParams]$checkDefaults
            $body.encryption = !$NoEncryption.IsPresent
        }

        if ($IMAP.IsPresent)
        {
            $checkDefaults.type = "imap"
            $body = [CheckPOPIMAPParams]$checkDefaults
            $body.encryption = !$NoEncryption.IsPresent
        }
        
        if ($TCP.IsPresent)
        { 
            $checkDefaults.type = "tcp"
            $body = [CheckTCPUDPParams]$checkDefaults 
        }

        if ($UDP.IsPresent)
        {
           $checkDefaults.type = "udp"
           $body = [CheckTCPUDPParams]$checkDefaults 
        }

        if ($PING.IsPresent)
        {
            $checkDefaults.type = "ping"
            $body = [CheckPINGParams]$checkDefaults
        }

        if ($HTTPCUSTOM.IsPresent)
        {
            $checkDefaults.type = "httpcustom"
            $body = [CheckHTTPCustomParams]$checkDefaults
        }

        if ($DNS.IsPresent)
        {
            $checkDefaults.type = "dns"
            $body = [CheckDNSParams]$checkDefaults
        }

        if (-not $body) { throw "Pingdom check type is undefined" }

        try {
            $PSBoundParameters.GetEnumerator() | 
            ? { ($body | gm -MemberType Properties, ScriptProperty).Name -contains $_.Key } | 
            % { $body."$($_.Key)" = $_.Value }
        
            $invokeParameters = @{
                Method = "POST"  # We are creating a new check
                Body = $body.ToHashTable()
                Uri = "checks"
            }

            if ($PSCmdlet.ShouldProcess("Create new check $Name"))
            {
                $response = Invoke-PingdomRestMethod @InvokeParameters
                Write-Verbose $response.check
                $newCheck = [PSCustomObject]$response.check
                $newCheck
            }
        }
        catch
        {
            Write-Error $_.Exception.Message
        }
    }
}
