Function Set-PingdomCheck
{
    <#

    .SYNOPSIS

    Function for modifying checks in Pingdom:  https://my.pingdom.com/newchecks/checks#

    .DESCRIPTION

    Grants the ability to Modify checks.  Simply pass the required information and it will be replaced with the data provided.

    DYNAMIC PARAMETERS
    
    --- DNS ---
    
    -ExpectedIP
        Change the Expected IP address
        e.g. Domain Nameserver (DNS) my.testdomain.com the "Expected IP" Should be 1.1.1.1

    -Nameserver
        Change the DNS Hostname e.g. Domain Nameserver (DNS) = my.testdomain.com.  You may want to review the Expected IP Address.

    --- HTTP ---
    
    -Url
        Change the Url portion of the check and not the Hostname e.g. if the Check is looking at https://www.mytestsite.com/login only the /login portion will change.  
        Please note a preceeding forward slash is required.

    -Auth
        Change the authentication parameter on the check itself.  e.g. HTTP basic auth.  This parameter expects a pscredential which can be created using either Get-Credential 
        OR if you want to automate:
        $sitecredential = [pscredential]::new("DOMAIN\Username", (ConvertTo-SecureString -String "mysecretplaintextstring" -AsPlainText -Force))

    -Port
        Change the port being checked e.g. HTTP default port is 80 but using this parameter you can change to any valid port.

    -Encryption
        Enable or Disable encryption.  Enables SSL/TLS e.g. switches from HTTP to HTTPS

    -ShouldContain
        The check response "should contain" the specified text e.g. the text "test" should be present on mytestsite.com

    -ShouldNotContain
        The check response "should not contain" the specified text e.g. the text "error" should NOT be present on mytestsite.com

    -PostData
        Data that should be posted to the web page, for example submission data for a sign-up or login form. 
        The data needs to be formatted in the same way as a web browser would send it to the web server
    
    --- HTTPCUSTOM ---

    -Url
        Change the Url portion of the check and not the Hostname e.g. if the Check is looking at https://www.mytestsite.com/login only the /login portion will change.  
        Please note a preceeding forward slash is required.
    
    -AdditionalUrls
        Change the additional urls to check.  Note this will wipe all existing additional urls.

    -Auth
        Change the authentication parameter on the check itself.  e.g. HTTP basic auth.  This parameter expects a pscredential which can be created using either Get-Credential 
        OR if you want to automate:
        $sitecredential = [pscredential]::new("DOMAIN\Username", (ConvertTo-SecureString -String "mysecretplaintextstring" -AsPlainText -Force))

    -Port
        Change the port being checked e.g. HTTP default port is 80 but using this parameter you can change to any valid port.

    -Encryption
        Enable or Disable encryption.  Enables SSL/TLS e.g. switches from HTTP to HTTPS

    --- SMTP ---

    -Auth
        Change the authentication parameter on the check itself.  e.g. HTTP basic auth.  This parameter expects a pscredential which can be created using either Get-Credential 
        OR if you want to automate:
        $sitecredential = [pscredential]::new("DOMAIN\Username", (ConvertTo-SecureString -String "mysecretplaintextstring" -AsPlainText -Force))

    -Port
        Change the port being checked e.g. HTTP default port is 80 but using this parameter you can change to any valid port.

    -Encryption
        Enable or Disable encryption.  Enables SSL/TLS e.g. switches from HTTP to HTTPS

    --- TCP ---
    
    -Port
        Change the port being checked e.g. HTTP default port is 80 but using this parameter you can change to any valid port.

    ---UDP ---

    -Port
        Change the port being checked e.g. HTTP default port is 80 but using this parameter you can change to any valid port.

    --- POP3 ---

    -Port
        Change the port being checked e.g. HTTP default port is 80 but using this parameter you can change to any valid port.

    -Encryption
        Enable or Disable encryption.  Enables SSL/TLS e.g. switches from HTTP to HTTPS

    --- IMAP ---
    
    -Port
        Change the port being checked e.g. HTTP default port is 80 but using this parameter you can change to any valid port.

    -Encryption
        Enable or Disable encryption.  Enables SSL/TLS e.g. switches from HTTP to HTTPS

    .PARAMETER Id
    An Id for a check must be specified.  Can use Get-PingdomChecks with filter to find the Id

    .PARAMETER Name
    Change the DisplayName for the check all Check types

    .PARAMETER Host
    Change the endpoint that you want to monitor e.g. from my.testsite.com to your.testsite.com can be either DNS name or IP Address

    .PARAMETER RequestHeaders
    Send Customer Headers to Website

    This is a http Parameter

    .PARAMETER StringToSend
    Send the this string to the Port specified in the check e.g. send "Hello"

    This is a TCP/UDP Parameter

    .PARAMETER StringToExpect
    This is the expected stirng to be returned from StringToSend parameter

    This is a TCP/UDP Parameter

    .PARAMETER IPv6
    Change to IP version 6, default is IPv4.

    This is a HTTP Parameter

    .PARAMETER Resolution
    Change the Check interval in minutes

    This is a universal Parameter

    .PARAMETER Tags
    Change the Tags associated with this check useful for filtering and reporting

    This is a universal Parameter

    .PARAMETER Probe_Filters
    Set where you would like the checks to be tested from from tests I have run it seems the only key value pairing this parameter accepts is region key.
    Set the value to "region: Default" to clear.

    Valid Values are: "region: NA", "region: EU", "region: APAC", "region: LATAM", "region: Default"

    "region: Default" is actually a dummy for an empty string but this doesn't play nicely with Tab Completion.

    For a list of Probes you can use Get-PingdomProbe and to find current regions you can do something like:
  
    Get-PingdomProbes | Group-Object Region | Select -ExpandProperty Name

    OR with correct formatting for Parameter
    
    (Get-PingdomProbes | Group-Object Region | Select -ExpandProperty Name) -replace "^(.*)", '"region: $1"' -join "," 

    This is a univeral Parameter
    
    .PARAMETER integrationids
    Link your checks to various integrations that you have set up.  Comma seperated string list e.g. 1,2,3.  For a List of integrations use Get-PingdomIntegrations function.

    This is a universal Parameter

    .PARAMETER UserIds
    Update the Users that alerts get sent to, for a list of Users use Get-PingdomUsers function

    This is a universal Parameter

    .PARAMETER TeamIds
    Update the Teams that alerts get sent to, for a list of Teams use Get-PingdomTeams function

    This is a universal Parameter

    .PARAMETER SendNotificationWhenDown
    Changes how quickly the check sends the alert.  On first time it's detected down? or second, third.  However please note that this is related to the resolution parameter 
    as you need to multiply them together to see when you'll get your first alert.
 
    This is a universal Parameter

    .PARAMETER NotifyAgainEvery
    Changes how often you will get subsequent alerts.  A zero value means no subsequent alerts, a value higher than zero has similar effect to SendNotificationWhenDown parameter.

    This is a universal Parameter

    .PARAMETER NotifyWhenBackUp
    Changes whether an alert is sent when service resumes.

    This is a universal Parameter

    .EXAMPLE
        Set-PingdomCheck -Id 123456 -Name "ChangeToThis" -Encryption True
        Change the name of the check 123456 to "ChangeToThis" and set to https
    
    .EXAMPLE
        Set-PingdomCheck -Id 123456 -Port 8080
        Change the listening port of the web site

    .EXAMPLE
        Get-PingdomChecks | Where-Object Name -eq "MyBestCheck" | Set-PingdomCheck -Encryption False

    #>

    [Cmdletbinding(SupportsShouldProcess)]
    Param
    (
        [parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [uint32]
        $Id,

        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateSet("http", "httpcustom", "tcp", "ping", "dns", "udp", "smtp", "pop3", "imap")]
        [string]
        $Type,

        [string]
        $Name,

        [string]
        $Host,

        [ValidateSet("1", "5", "15", "30", "60")]
        [Alias("Interval")]
        [string]
        $Resolution,

        [ValidateSet("True", "False")]
        [string]
        $IPv6,

        [string[]]
        $Tags,

        # NA = North America, EU = Europe, APAC = Asia Pacific, LATAM = Latin America
        [ValidateSet("region:NA", "region:EU", "region:APAC", "region:LATAM", "default")]
        [string[]]
        $Probe_Filters,

        # in milliseconds (ms), Default = 30000 (30 seconds)
        [ValidateRange(1, [int32]::MaxValue)]
        [string]
        $Responsetime_Threshold,

        [ValidateRange(1, [int32]::MaxValue)]
        [string[]]
        $Integrationids,

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

        [ValidateSet("True", "False")]
        [string]
        $NotifyWhenBackUp
    )

    DynamicParam
    {
        $dictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
        $paramArray = @()

        if ($Type -eq "http")
        {
            $paramArray = @{
                ParameterName = "ShouldContain"
                ParamType = [string]
                ParameterSetName = "HTTPCheck_1"
            },@{
                ParameterName = "ShouldNotContain"
                ParamType = [string]
                ParameterSetName = "HTTPCheck_1"
            }, @{
                ValidatePattern = "^/"
                ParameterName = "Url"
                ParamType = [string]
                ParameterSetName = "HTTPCheck_1"
            }, @{
                ParameterName = "Auth"
                ParamType = [pscredential]
                ParameterSetName = "HTTPCheck_1"
            },@{
                ValidateRange = 1, [uint16]::MaxValue
                ParameterName = "Port"
                ParamType = [uint32]
                ParameterSetName = "HTTPCheck_1"
            }, @{
                ValidateSet = "True", "False"
                ParameterName = "Encryption"
                ParamType = [string]
                ParameterSetName = "HTTPCheck_1"
            },@{
                ValidateNotNullOrEmpty = [switch]::Present
                ParameterName = "PostData"
                ParamType = [string]
                ParameterSetName = "HTTPCheck_1"
            }, @{
                ValidatePattern = "^(?:\w|\W)+:(?:\w|\W)+$"
                ParameterName = "RequestHeaders"
                ParamType = [string[]]
                ParameterSetName = "HTTPCheck_1"
            } 
        }

        if ($Type -eq "httpcustom")
        {
            $paramArray = @{
                ValidatePattern = "^/"
                ParameterName = "Url"
                ParamType = [string]
                ParameterSetName = "HTTPCustomCheck_1"
            },@{
                ValidateScript = {
                    [uri]::TryCreate($_, [System.UriKind]::Absolute, [ref]$_)
                }
                ParameterName = "AdditionalUrls"
                ParamType = [string[]]
                ParameterSetName = "HTTPCustomCheck_1"
            },@{
                ParameterName = "Auth"
                ParamType = [pscredential]
                ParameterSetName = "HTTPCustomCheck_1"
            },@{
                ValidateRange = 1, [uint16]::MaxValue
                ParameterName = "Port"
                ParamType = [uint32]
                ParameterSetName = "HTTPCustomCheck_1"
            },@{
                ValidateSet = "True", "False"
                ParameterName = "Encryption"
                ParamType = [string]
                ParameterSetName = "HTTPCustomCheck_1"
            }
        }

        if ($Type -eq "dns")
        {
            $paramArray = @{
                ParameterName = "ExpectedIP"
                ParamType = [string]
                ParameterSetName = "DNSCheck_1"
            },@{
                ParameterName = "NameServer"
                ParamType = [string]
                ParameterSetName = "DNSCheck_1"
            }
        }

        if ($Type -eq "smtp")
        {
             $paramArray = @{
                ParameterName = "Auth"
                Alias = "webcredential", "smtpcredential"
                ParamType = [pscredential]
                ParameterSetName = "SMTPCheck_1"
            },@{
                ValidateRange = 1, [uint16]::MaxValue
                ParameterName = "Port"
                ParamType = [uint32]
                ParameterSetName = "SMTPCheck_1"
            },@{
                ValidateSet = "True", "False"
                ParameterName = "Encryption"
                ParamType = [string]
                ParameterSetName = "SMTPCheck_1"
            },@{
                ValidateNotNullOrEmpty = [switch]::Present
                ParameterName = "StringToExpect"
                ParamType = [string]
                ParameterSetName = "SMTPCheck_1"
            }
        }

        if ($Type -eq "pop3")
        {
            $paramArray = @{
                ValidateRange = 1, [uint16]::MaxValue
                ParameterName = "Port"
                ParamType = [uint32]
                ParameterSetName = "POP3Check_1"
            },@{
                ValidateSet = "True", "False"
                ParameterName = "Encryption"
                ParamType = [string]
                ParameterSetName = "POP3Check_1"
            },@{
                ValidateNotNullOrEmpty = [switch]::Present
                ParameterName = "StringToExpect"
                ParamType = [string]
                ParameterSetName = "POP3Check_1"
            }
        }

        if ($Type -eq "imap")
        {
            $paramArray = @{
                ValidateRange = 1, [uint16]::MaxValue
                ParameterName = "Port"
                ParamType = [uint32]
                ParameterSetName = "IMAPCheck_1"
            },@{
                ValidateSet = "True", "False"
                ParameterName = "Encryption"
                ParamType = [string]
                ParameterSetName = "IMAPCheck_1"
            },@{
                ValidateNotNullOrEmpty = [switch]::Present
                ParameterName = "StringToExpect"
                ParamType = [string]
                ParameterSetName = "IMAPCheck_1"
            }
        }

        if ($Type -eq "tcp")
        {
            $paramArray = @{
                ValidateRange = 1, [uint16]::MaxValue
                ParameterName = "Port"
                ParamType = [uint32]
                ParameterSetName = "TCPCheck_1"
            },@{
                ValidateNotNullOrEmpty = [switch]::Present
                ParameterName = "StringToSendParams"
                ParamType = [string]
                ParameterSetName = "TCPCheck_1"
            },@{
                ValidateNotNullOrEmpty = [switch]::Present
                ParameterName = "StringToExpect"
                ParamType = [string]
                ParameterSetName = "TCPCheck_1"
            }
        }


        if ($Type -eq "udp")
        {
            $paramArray = @{
                ValidateRange = 1, [uint16]::MaxValue
                ParameterName = "Port"
                ParamType = [uint32]
                ParameterSetName = "UDPCheck_1"
            },@{
                ValidateNotNullOrEmpty = [switch]::Present
                ParameterName = "StringToSendParams"
                ParamType = [string]
                ParameterSetName = "UDPCheck_1"
            },@{
                ValidateNotNullOrEmpty = [switch]::Present
                ParameterName = "StringToExpect"
                ParamType = [string]
                ParameterSetName = "UDPCheck_1"
            }
        }

        $paramArray |
            %{
                $runtimParam = New-DynamicParam @_
                $dictionary.Add($runtimParam.Name, $runtimParam)
            }
            $dictionary
    }

    Begin
    {
        # Dynamic Parameters don't support multiple Parameter sets
        if (($PSCmdlet.ParameterSetName -eq "HTTPCheck_1" ) -and
            ($PSBoundParameters."ShouldContain" -and $PSBoundParameters."ShouldNotContain")
        )
        {
            throw "ShouldContain and ShouldNotContain cannot both be set"
        }

        Test-PingdomAuthToken
    }

    Process
    {
        foreach ($item in $Id)
        {
            $body = Get-PingdomCheckType -Type $type
            $MyInvocation.BoundParameters.Remove("type") | Out-Null
            $boundParams = $MyInvocation.BoundParameters.GetEnumerator()
            $boundParams | 
                ?{ ($body | gm | Select -ExpandProperty Name) -contains $_.Key  } | 
                    %{ 
                        if ($_.Key -eq "probe_filters" -and $_.Value -eq "default")
                        {
                            $body."$($_.Key)" = ""
                        }
                        else
                        {
                            $body."$($_.Key)" = $_.Value 
                        }
                     }

            if ($PSCmdlet.ShouldProcess("Modifying check $Id") )
            {
                try
                {
                    $invokeParameters = @{
                        Method = "PUT"
                        Body = $body.ToHashTable()
                        Uri = "checks/$Id"
                    }

                    if ($invokeParameters.Body.Count)
                    {
                        $response = Invoke-PingdomRestMethod @InvokeParameters
                        Write-Verbose "$($response.message)"
                    }
                    else
                    {
                        $OriginalBGColor = $Global:Host.UI.RawUI.BackgroundColor
                        $Global:Host.UI.WriteLine([System.ConsoleColor]::DarkYellow, $OriginalBGColor, "No valid Parameters were defined for check type: $Type")
                        $Global:Host.UI.RawUI.BackgroundColor = $OriginalBGColor
                    }
                }
                catch
                {
                    Write-Error "Unable to modify check: $_"
                    break
                }
            }
        }
    }
}