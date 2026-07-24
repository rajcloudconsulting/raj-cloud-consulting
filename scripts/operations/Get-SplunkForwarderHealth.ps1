<#
.SYNOPSIS
    Report Splunk Universal Forwarder health

.DESCRIPTION
    Reports service state, executable version where available and selected local configuration-file metadata without revealing configuration contents.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

$serviceNames = 'SplunkForwarder','splunkforwarder'
$service = Get-Service -Name $serviceNames -ErrorAction SilentlyContinue | Select-Object -First 1

$possibleHomes = @(
    "$env:ProgramFiles\SplunkUniversalForwarder",
    '/opt/splunkforwarder'
)

$home = $possibleHomes | Where-Object { Test-Path $_ } | Select-Object -First 1
$binary = if ($IsLinux) { Join-Path $home 'bin/splunk' } else { Join-Path $home 'bin/splunk.exe' }

$configFiles = if ($home) {
    Get-ChildItem -Path (Join-Path $home 'etc') -Filter '*.conf' -Recurse -File -ErrorAction SilentlyContinue |
        Select-Object FullName, Length, LastWriteTime
}

[pscustomobject]@{
    ServiceName = $service.Name
    ServiceStatus = $service.Status
    InstallHome = $home
    BinaryPresent = Test-Path $binary
    ConfigurationFileCount = @($configFiles).Count
} | Format-List
