<#
.SYNOPSIS
    Inventory Microsoft 365 application components

.DESCRIPTION
    Inventories selected Microsoft 365, Teams, OneDrive and WebView2 installation information from standard local sources.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

$uninstallRoots = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)

$patterns = 'Microsoft 365|Microsoft Office|Microsoft Teams|OneDrive|WebView2'
$apps = Get-ItemProperty $uninstallRoots -ErrorAction SilentlyContinue |
    Where-Object DisplayName -match $patterns |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object DisplayName -Unique

$apps | Format-Table -AutoSize
