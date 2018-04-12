Function Get-PingdomChecks
{
     <#

    .SYNOPSIS

    Function for retrieving all checks in Pingdom:  https://my.pingdom.com/newchecks/checks#

    .DESCRIPTION
    Shows all checks and status's with following properties
    
    acktimeout       
    alert_policy_name
    autoresolve      
    created          
    encryption - (exposed optionally by pingdom API but included by default in this module)      
    hostname         
    id               
    ipv6             
    lasterrortime    
    lastresponsetime 
    lasttesttime     
    name             
    resolution       
    severity_level - (exposed optionally by pingdom API but included by default in this module) 
    status           
    tags - (exposed optionally by pingdom API but included by default in this module)       
    type    

    .PARAMETER
       None

    .EXAMPLE
        PS C:\> Get-PingdomChecks

        Gets all Checks

    #>

    Begin
    {
        Test-PingdomAuthToken
    }

    Process
    {
        $invokeParameters = @{
            Method = "GET"
            Uri = "checks"
            Body = @{
                showencryption = $true
                include_tags = $true
                include_severity = $true
            }
        }

        $response = Invoke-PingdomRestMethod @invokeParameters
        $response.checks
    } 
}
