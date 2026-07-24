<#
.SYNOPSIS
    Report Microsoft Defender endpoint health

.DESCRIPTION
    Reports Defender service, antivirus status and selected preference values using built-in Defender cmdlets.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

$service = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
$status = Get-MpComputerStatus -ErrorAction SilentlyContinue
$preferences = Get-MpPreference -ErrorAction SilentlyContinue

[pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    ServiceStatus = $service.Status
    AntivirusEnabled = $status.AntivirusEnabled
    RealTimeProtectionEnabled = $status.RealTimeProtectionEnabled
    BehaviorMonitorEnabled = $status.BehaviorMonitorEnabled
    IoavProtectionEnabled = $status.IoavProtectionEnabled
    AntivirusSignatureAge = $status.AntivirusSignatureAge
    CloudBlockLevel = $preferences.CloudBlockLevel
    PUAProtection = $preferences.PUAProtection
    SubmitSamplesConsent = $preferences.SubmitSamplesConsent
} | Format-List
