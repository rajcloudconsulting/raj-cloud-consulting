<#
.SYNOPSIS
    Creates a basic Windows endpoint health report.

.DESCRIPTION
    Collects non-sensitive local information including operating system,
    uptime, free disk space, BitLocker state, Defender service status and
    common pending-reboot indicators.

.NOTES
    Run in PowerShell 5.1 or later. Test in a non-production environment first.
#>

[CmdletBinding()]
param(
    [string]$OutputPath = "$env:TEMP\WindowsEndpointHealth.json"
)

$ErrorActionPreference = 'Stop'

function Get-PendingRebootState {
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    )

    foreach ($path in $paths) {
        if (Test-Path -LiteralPath $path) {
            return $true
        }
    }

    $sessionManager = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
    $pendingRename = Get-ItemProperty -Path $sessionManager -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
    return $null -ne $pendingRename
}

$os = Get-CimInstance -ClassName Win32_OperatingSystem
$systemDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$($env:SystemDrive)'"

$bitLocker = if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {
    Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue |
        Select-Object MountPoint, VolumeStatus, ProtectionStatus, EncryptionPercentage
} else {
    $null
}

$defenderService = Get-Service -Name WinDefend -ErrorAction SilentlyContinue

$report = [ordered]@{
    ComputerName        = $env:COMPUTERNAME
    CollectedAtUtc      = (Get-Date).ToUniversalTime().ToString('o')
    OperatingSystem     = $os.Caption
    OSVersion           = $os.Version
    LastBootTime        = $os.LastBootUpTime
    UptimeDays          = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalDays, 2)
    SystemDrive         = $env:SystemDrive
    FreeSpaceGB         = [math]::Round($systemDrive.FreeSpace / 1GB, 2)
    TotalSpaceGB        = [math]::Round($systemDrive.Size / 1GB, 2)
    PendingReboot       = Get-PendingRebootState
    DefenderService     = $defenderService.Status
    BitLocker           = $bitLocker
}

$report | ConvertTo-Json -Depth 5 | Set-Content -Path $OutputPath -Encoding UTF8
$report
Write-Output "Report saved to: $OutputPath"
