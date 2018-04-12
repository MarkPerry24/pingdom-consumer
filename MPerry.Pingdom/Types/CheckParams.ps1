Class CheckBaseParams
{
    [string]
    $name

    [string]
    $host

    [ValidateSet("http", "httpcustom", "tcp", "ping", "dns", "udp", "smtp", "pop3", "imap")]
    [string]
    $type

    [ValidateSet("True", "False")]
    [string]
    $paused

    [ValidateSet("1", "5", "15", "30", "60")]
    [Alias("Interval")]
    [string]
    $resolution

    [ValidateRange(0,[int32]::MaxValue)]
    [string[]]
    $userids

    [ValidateRange(1,10)]
    [string]
    $sendnotificationwhendown

    [ValidateRange(0,60)]
    [string]
    $notifyagainevery

    [ValidateSet("True", "False")]
    [string]
    $notifywhenbackup

    [string[]]
    $tags

    # NA = North America, EU = Europe, APAC = Asia Pacific, LATAM = Latin America
    [ValidateSet("region:NA", "region:EU", "region:APAC", "region:LATAM", "")]
    [string[]]
    $probe_filters

    [ValidateSet("True", "False")]
    [string]
    $ipv6

    [ValidateRange(0, [int32]::MaxValue)]
    [string]
    $responsetime_threshold

    [ValidateRange(0, [int32]::MaxValue)]
    [string[]]
    $integrationids

    [ValidateRange(0, [int32]::MaxValue)]
    [string[]]
    $teamids

    [ValidateRange(0, [int32]::MaxValue)]
    [string]
    $alert_policy

    [ValidateSet("True", "False")]
    [string]
    $use_legacy_notifications


    CheckBaseParams()
    {
        if ($this.GetType() -is [CheckBaseParams])
        {
            throw "base type must be inherited"
        }
    }

    [hashtable]ToHashTable()
    {
        [hashtable]$props = @{}
        
        foreach ($prop in $this.psobject.properties)
        {
            foreach ($item in $this.$($prop.Name))
            {
                if ($item -ne $null)
                {
                    $props.Add($($prop.Name), $this.$($prop.Name) -join ",")
                }
            }
        }
        
        return $props
    }
}

Class CheckHTTPParams : CheckBaseParams
{
    [ValidateSet("True", "False")]
    [string]
    $sendtoemail

    [ValidateRange(1,[uint16]::MaxValue)]
    [string]
    $port

    hidden
    [string]
    $_shouldcontain

    hidden
    [string]
    $_shouldnotcontain

    [string]
    $url

    [ValidateSet("True", "False")]
    [string]
    $encryption

    [string[]]
    $requestheaders

    [string]
    $postdata

    hidden
    [string]
    $_auth

    CheckHTTPParams() 
    {
        $this.psobject.properties.add(
            [psscriptproperty]::new(
                "shouldcontain",
                {
                    $this._shouldcontain
                },
                { 
                    param
                    (
                        [string]
                        $sc
                    ) 
                    
                    if ($this._shouldnotcontain)
                    {
                        throw "ShouldContain and ShouldNotContain Cannot both be set"
                    }
                    else
                    {
                        $this._shouldcontain = $sc
                    }
                }
            )
        )

        $this.psobject.properties.add(
            [psscriptproperty]::new(
                "shouldnotcontain",
                {
                    $this._shouldnotcontain
                },
                { 
                    param
                    (
                        [string]
                        $snc
                    ) 
                    
                    if ($this._shouldcontain)
                    {
                        throw "ShouldContain and ShouldNotContain Cannot both be set"
                    }
                    else
                    {
                        $this._shouldnotcontain = $snc
                    }
                }
            )
        )

        $this.psobject.properties.add(
            [psscriptproperty]::new(
                "auth",
                {
                    $this._auth
                },
                { 
                    param
                    (
                        [pscredential]
                        $cred
                    ) 
                    
                    $this._auth = "$($Cred.UserName):$($Cred.GetNetworkCredential().Password)"
                }
            )
        )
    }

    [hashtable]
    ToHashTable()
    {
        if ($this.requestheaders)
        {
            [hashtable]
            $this.requestheaders = $this.requestheaders | %{
                $i = 1
                $rqhdrs = @{}
            }{
                $rqhdrs."requestheader$i" = $_
            }
            {
               $rqhdrs
            }
        }

        return ([CheckBaseParams]$this).ToHashTable()
    }
}

Class CheckTCPUDPParams : CheckBaseParams
{
    [string]
    $stringtosend

    [string]
    $stringtoexpect

    [ValidateRange(1,65535)]
    [string]
    $port
}

Class CheckPINGParams : CheckBaseParams
{
}

Class CheckHTTPCustomParams : CheckBaseParams
{
    [string[]]
    $additionalurls

    [ValidatePattern("^/")]
    [string]
    $url

    [hashtable]
    TohashTable()
    {
        $this.AdditionalUrls = $this.AdditionalUrls -join ";"
        return ([CheckBaseParams]$this).ToHashTable()
    }
}

Class CheckDNSParams : CheckBaseParams
{
        [string]
        $expectedip

        [string]
        $nameserver
}

Class CheckSMTParams : CheckBaseParams
{
    [ValidateRange(1,[uint16]::MaxValue)]
    [string]
    $port

    hidden
    [string]
    $_auth

    [string]
    $stringtoexpect	

    [ValidateSet("True", "False")]
    [string]
    $encryption

    CheckSMTPParams()
    {
        $this.psobject.properties.add(
            [psscriptproperty]::new(
                "auth",
                {
                    $this._auth
                },
                { 
                    param
                    (
                        [pscredential]
                        $cred
                    ) 
                    
                    $this._auth = "$($Cred.UserName):$($Cred.GetNetworkCredential().Password)"
                }
            )
        )
    }
}

Class CheckPOPIMAPParams : CheckBaseParams
{
    [ValidateRange(1,[uint16]::MaxValue)]
    [string]
    $port

    [string]
    $stringtoexpect	

    [ValidateSet("True", "False")]
    [string]
    $encryption
}
