<#
.SYNOPSIS
    Reports BitLocker status for local fixed volumes.

.DESCRIPTION
    Produces console output and an optional CSV export.
#>

[CmdletBinding()]
param(
    [string]$CsvPath
)

if (-not (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue)) {
    throw 'Get-BitLockerVolume is unavailable on this system.'
}

$report = Get-BitLockerVolume |
    Where-Object VolumeType -eq 'OperatingSystem' |
    Select-Object MountPoint, VolumeStatus, ProtectionStatus, EncryptionMethod, EncryptionPercentage

$report | Format-Table -AutoSize

if ($CsvPath) {
    $report | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8
    Write-Output "CSV saved to: $CsvPath"
}
