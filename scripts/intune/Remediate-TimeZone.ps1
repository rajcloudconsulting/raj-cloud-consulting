<#
.SYNOPSIS
    Set the Windows time zone

.DESCRIPTION
    Parameterised remediation for configuring a Windows time zone and validating the resulting setting.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$TimeZoneId
)

$available = Get-TimeZone -ListAvailable | Where-Object Id -eq $TimeZoneId
if (-not $available) {
    throw "Unknown Windows time zone ID: $TimeZoneId"
}

$current = Get-TimeZone
if ($current.Id -ne $TimeZoneId) {
    Set-TimeZone -Id $TimeZoneId
}

$verified = Get-TimeZone
if ($verified.Id -ne $TimeZoneId) {
    throw "Time zone verification failed. Current value: $($verified.Id)"
}

Write-Output "Configured time zone: $($verified.Id)"
