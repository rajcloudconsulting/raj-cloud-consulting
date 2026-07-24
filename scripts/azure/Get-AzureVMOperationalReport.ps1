<#
.SYNOPSIS
    Create an Azure VM operational report

.DESCRIPTION
    Produces a generic VM inventory including power state, size, operating system and identity type using the Az module.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding()]
param(
    [string]$SubscriptionId
)

if (-not (Get-Module -ListAvailable -Name Az.Compute)) {
    throw 'Az.Compute module is required.'
}

if ($SubscriptionId) {
    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
}

Get-AzVM -Status | ForEach-Object {
    $power = $_.Statuses | Where-Object Code -like 'PowerState/*' | Select-Object -First 1
    [pscustomobject]@{
        ResourceGroup = $_.ResourceGroupName
        Name = $_.Name
        Location = $_.Location
        VmSize = $_.HardwareProfile.VmSize
        OsType = $_.StorageProfile.OsDisk.OsType
        PowerState = $power.DisplayStatus
        IdentityType = $_.Identity.Type
    }
} | Sort-Object ResourceGroup, Name
