<#
.SYNOPSIS
    Collect Intune Management Extension diagnostics

.DESCRIPTION
    Collects service status, recent relevant event log entries and log-file metadata without copying tenant-specific log contents.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding()]
param(
    [string]$OutputPath = "$env:TEMP\IntuneDiagnostics.json"
)

$service = Get-Service -Name IntuneManagementExtension -ErrorAction SilentlyContinue
$logFolder = "${env:ProgramData}\Microsoft\IntuneManagementExtension\Logs"

$logMetadata = if (Test-Path -LiteralPath $logFolder) {
    Get-ChildItem -LiteralPath $logFolder -File -ErrorAction SilentlyContinue |
        Select-Object Name, Length, LastWriteTime
}

$events = Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin'
    StartTime=(Get-Date).AddDays(-1)
} -MaxEvents 50 -ErrorAction SilentlyContinue |
Select-Object TimeCreated, Id, LevelDisplayName, ProviderName

$result = [ordered]@{
    CollectedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    ComputerName = $env:COMPUTERNAME
    ServiceStatus = $service.Status
    ServiceStartType = $service.StartType
    LogMetadata = $logMetadata
    RecentEvents = $events
}

$result | ConvertTo-Json -Depth 5 | Set-Content -Path $OutputPath -Encoding UTF8
Write-Output "Diagnostics metadata saved to $OutputPath"
