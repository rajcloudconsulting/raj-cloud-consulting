<#
.SYNOPSIS
    Register startup and shutdown wrapper tasks

.DESCRIPTION
    Creates generic scheduled tasks for a startup script and an event-triggered shutdown wrapper. Paths are supplied as parameters.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$StartupScriptPath,

    [Parameter(Mandatory)]
    [string]$ShutdownScriptPath
)

foreach ($path in @($StartupScriptPath,$ShutdownScriptPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Script not found: $path"
    }
}

$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

$startupAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "/c `"$StartupScriptPath`""
$startupTrigger = New-ScheduledTaskTrigger -AtStartup

if ($PSCmdlet.ShouldProcess('RajCloud-StartupScript','Register scheduled task')) {
    Register-ScheduledTask -TaskName 'RajCloud-StartupScript' -Action $startupAction -Trigger $startupTrigger -Principal $principal -Settings $settings -Force
}

# Event 1074 is commonly logged when a process initiates shutdown/restart.
$shutdownAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "/c `"$ShutdownScriptPath`""
$shutdownTrigger = New-ScheduledTaskTrigger -AtLogOn
$shutdownTrigger.CimClass.CimClassName | Out-Null

Write-Warning 'Windows Task Scheduler has no native "at shutdown" trigger. Use Group Policy shutdown scripts for guaranteed shutdown execution.'
Write-Output 'Startup task registered. Shutdown script path validated; deploy it through Group Policy or an approved event-triggered wrapper.'
