# pingdom-consumer
Pingdom Api Consumer

This is an initial release.  As far as I know this is far more full featured than anything else around and I was intending to implement a full support for the Pingdom API but upon reflection implemented the most common tasks with a view to implementing upon request as some of the features look like they would not see much usage.

This can be used by extracting and running: 
"Import-Module (path to Mperry.Pingdom folder)" in powershell cli 
OR
Extracting to a path included in PSModulePath and just reopening powershell cli

So far we have support for: 

Retrieving information about:

    Alerts
    Checks - Two types basic and Advanced 
        via Get-PingdonChecks and Get-PingdomCheck the latter getting full information the former summary
    Check Analysis (Most usage scenarios)
    Check Analysis Raw (Advanced undocumented by Pingdom themselves)
    Probes
    Teams
    Users
    Creating New Checks
    Modifying Checks
    Removing Checks
    Stopping Checks
    Starting Checks

Please review the help on each command after importing the module e.g.

Get-Command -Module MPerry.Pingdom | Get-Help -detailed

I hope this helps anyone wishing to automate using Pingdom