<#
.SYNOPSIS
    Previews or removes common temporary files.

.DESCRIPTION
    Uses preview mode by default. Specify -Execute to remove eligible files.
    This script does not touch user documents, downloads or browser profiles.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Execute,
    [int]$OlderThanDays = 7
)

$cutoff = (Get-Date).AddDays(-$OlderThanDays)
$targets = @(
    $env:TEMP,
    "$env:WINDIR\Temp"
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique

$files = foreach ($target in $targets) {
    Get-ChildItem -LiteralPath $target -File -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object LastWriteTime -lt $cutoff
}

$totalBytes = ($files | Measure-Object Length -Sum).Sum
Write-Output ("Eligible files: {0}" -f $files.Count)
Write-Output ("Estimated space: {0:N2} MB" -f ($totalBytes / 1MB))

if (-not $Execute) {
    Write-Output 'Preview only. Re-run with -Execute to remove eligible files.'
    return
}

foreach ($file in $files) {
    if ($PSCmdlet.ShouldProcess($file.FullName, 'Remove temporary file')) {
        Remove-Item -LiteralPath $file.FullName -Force -ErrorAction SilentlyContinue
    }
}
