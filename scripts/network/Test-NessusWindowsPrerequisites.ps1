<#
.SYNOPSIS
    Audit Windows authenticated-scan prerequisites

.DESCRIPTION
    Audits services, firewall rules and administrative shares commonly required for authenticated Windows vulnerability scanning.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

$services = 'RemoteRegistry','Winmgmt','LanmanServer'
$serviceReport = foreach ($name in $services) {
    $service = Get-Service -Name $name -ErrorAction SilentlyContinue
    [pscustomobject]@{
        Component = "Service:$name"
        Present = [bool]$service
        Status = $service.Status
        StartType = $service.StartType
    }
}

$firewallGroups = 'Windows Management Instrumentation (WMI)','File and Printer Sharing'
$firewallReport = foreach ($group in $firewallGroups) {
    $rules = Get-NetFirewallRule -DisplayGroup $group -ErrorAction SilentlyContinue
    [pscustomobject]@{
        Component = "Firewall:$group"
        Present = [bool]$rules
        EnabledRules = ($rules | Where-Object Enabled -eq 'True').Count
    }
}

$adminShare = Test-Path '\\localhost\ADMIN$'
$serviceReport
$firewallReport
[pscustomobject]@{ Component='Administrative share'; Present=$adminShare }
