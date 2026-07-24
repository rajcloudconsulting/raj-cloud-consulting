<#
.SYNOPSIS
    Test the Teams Outlook add-in

.DESCRIPTION
    Checks common registry and installation indicators for the Microsoft Teams meeting add-in used by Outlook.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

$paths = @(
    'HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect',
    'HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect'
)

$result = foreach ($path in $paths) {
    if (Test-Path $path) {
        [pscustomobject]@{
            RegistryPath = $path
            Present = $true
            LoadBehavior = Get-ItemPropertyValue -Path $path -Name LoadBehavior -ErrorAction SilentlyContinue
        }
    } else {
        [pscustomobject]@{ RegistryPath=$path; Present=$false; LoadBehavior=$null }
    }
}

$result | Format-Table -AutoSize
if (($result | Where-Object { $_.Present -and $_.LoadBehavior -eq 3 }).Count -gt 0) { exit 0 }
exit 1
