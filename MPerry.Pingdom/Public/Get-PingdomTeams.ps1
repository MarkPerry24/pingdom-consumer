Function Get-PingdomTeams
{
    <#

    .SYNOPSIS

    Function for retrieving contacts in Pingdom:  https://my.pingdom.com/teams#

    .DESCRIPTION

    Function is used for getting user information e.g. the id field as it's not possible to configure basic alerts without the id field.

    .EXAMPLE
        New-PingdomAuthToken [pscredential]::new("username", "securestring")
        Get-PingdomTeams | ?{$_.name -match "Name"} | Select name,id
        Retrive the Teams list and filter to Team with "Name" in the name field.

    .EXAMPLE
        New-PingdomAuthToken [pscredential]::new("username", "securestring")
        Get-PingdomTeams | ?{$_.name -match "Name"} | Select name,id
        As above but piping $authtoken to cmdlet
    #>

    $invokeParameters = @{
        Method = "GET"
        Uri = "teams"
    }

    $teams = Invoke-PingdomRestMethod @InvokeParameters
    $teams.teams
}
