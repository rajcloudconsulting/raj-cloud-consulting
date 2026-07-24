<#
.SYNOPSIS
    Report FSLogix configuration and service health

.DESCRIPTION
    Reports FSLogix service state and selected non-secret configuration values useful for troubleshooting profile-container issues.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

$service = Get-Service -Name frxsvc -ErrorAction SilentlyContinue
$profilePath = 'HKLM:\SOFTWARE\FSLogix\Profiles'

$properties = if (Test-Path $profilePath) {
    Get-ItemProperty -Path $profilePath |
        Select-Object Enabled, VHDLocations, VolumeType, DeleteLocalProfileWhenVHDShouldApply,
                      FlipFlopProfileDirectoryName, IsDynamic, SizeInMBs
}

[pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    ServiceInstalled = [bool]$service
    ServiceStatus = $service.Status
    ServiceStartType = $service.StartType
    ProfileConfiguration = $properties
} | Format-List
