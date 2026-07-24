<#
.SYNOPSIS
    Detect Windows and Microsoft Edge Copilot configuration

.DESCRIPTION
    Intune detection script that checks Windows Copilot and Microsoft Edge Copilot-related policy values.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

$checks = @(
    @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot'; Name='TurnOffWindowsCopilot'; Expected=1 },
    @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Edge'; Name='EdgeCopilotEnabled'; Expected=0 },
    @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Edge'; Name='Microsoft365CopilotChatIconEnabled'; Expected=0 },
    @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Edge'; Name='HubsSidebarEnabled'; Expected=0 }
)

$issues = [System.Collections.Generic.List[string]]::new()
foreach ($check in $checks) {
    $value = Get-ItemPropertyValue -Path $check.Path -Name $check.Name -ErrorAction SilentlyContinue
    if ($value -ne $check.Expected) {
        $issues.Add("$($check.Path)\$($check.Name) expected $($check.Expected), found $value")
    }
}

$copilotPackages = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match 'Copilot' }

if ($copilotPackages) {
    $issues.Add("Copilot AppX package remains installed")
}

if ($issues.Count -eq 0) {
    Write-Output "Compliant: Copilot controls are configured."
    exit 0
}

Write-Output ("Non-compliant: " + ($issues -join " | "))
exit 1
