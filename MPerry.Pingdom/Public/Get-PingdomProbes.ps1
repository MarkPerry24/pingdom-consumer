Function Get-PingdomProbes
{
     <#

    .SYNOPSIS

    Function for retrieving all checks in Pingdom:  https://my.pingdom.com/newchecks/checks#

    .DESCRIPTION

    .PARAMETER
       None

    .EXAMPLE
        PS C:\> Get-PingdomProbes

        Gets all Probes

    #>

    param
    (
        [ValidateRange(1,100)]
        [uint16]
        $Limit,

        [ValidateSet("True", "False")]
        [string]
        $OnlyActive,

        [ValidateSet("True", "False")]
        [string]
        $OnlyTMS,

        [ValidateSet("True", "False")]
        [string]
        $IncludeDeleted
    )

    Begin
    {
        Test-PingdomAuthToken
    }

    Process
    {
        $invokeParameters = @{
            Method = "GET"
            Uri = "probes"
        }

        $response = Invoke-PingdomRestMethod @invokeParameters
        $response.probes
    } 
}