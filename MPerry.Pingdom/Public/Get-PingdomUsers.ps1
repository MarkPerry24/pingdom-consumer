Function Get-PingdomUsers
{
    <#

    .SYNOPSIS

    Function for retrieving contacts in Pingdom:  https://my.pingdom.com/users#

    .DESCRIPTION

    Function is used for getting user information e.g. the id field as it's not possible to configure basic alerts without the id field.

    .EXAMPLE
        New-PingdomAuthToken [pscredential]::new("username", "securestring")
        Get-PingdomUsers | ?{$_.name -match "Name"} | Select name,id
        Retrive the users list and filter to contact with "Name" in the name field.

    .EXAMPLE
        New-PingdomAuthToken [pscredential]::new("username", "securestring")
        Get-PingdomUsers | ?{$_.name -match "Name"} | Select name,id
        As above but piping $authtoken to cmdlet
    #>
    $invokeParameters = @{
        Method = "GET"
        Uri = "users"
    }

    $users = Invoke-PingdomRestMethod @InvokeParameters
    $users.users
}
