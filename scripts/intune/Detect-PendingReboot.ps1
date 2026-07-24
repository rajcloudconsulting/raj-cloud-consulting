<#
.SYNOPSIS
    Detect a pending Windows restart

.DESCRIPTION
    Intune detection script for common component servicing, Windows Update and pending file rename restart indicators.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

$pending = [System.Collections.Generic.List[string]]::new()

$registryChecks = @{
    'ComponentBasedServicing' = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    'WindowsUpdate' = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
}

foreach ($item in $registryChecks.GetEnumerator()) {
    if (Test-Path -LiteralPath $item.Value) {
        $pending.Add($item.Key)
    }
}

$sessionManager = Get-ItemProperty `
    -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
    -Name PendingFileRenameOperations `
    -ErrorAction SilentlyContinue

if ($sessionManager.PendingFileRenameOperations) {
    $pending.Add('PendingFileRenameOperations')
}

if ($pending.Count -eq 0) {
    Write-Output 'Compliant: no pending restart indicators found.'
    exit 0
}

Write-Output ("Restart pending: " + ($pending -join ', '))
exit 1
