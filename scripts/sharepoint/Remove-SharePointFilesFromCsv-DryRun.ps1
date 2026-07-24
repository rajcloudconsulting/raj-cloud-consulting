<#
.SYNOPSIS
    Plan SharePoint file deletion from CSV

.DESCRIPTION
    Validates a CSV file list and defaults to dry-run behaviour. Actual deletion requires an explicit switch and an established PnP connection.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$CsvPath,

    [switch]$Execute
)

if (-not (Get-Command Get-PnPFile -ErrorAction SilentlyContinue)) {
    throw 'PnP.PowerShell is required and an authenticated connection must already exist.'
}

$rows = Import-Csv -Path $CsvPath
foreach ($row in $rows) {
    $serverRelativeUrl = $row.ServerRelativeUrl
    if ([string]::IsNullOrWhiteSpace($serverRelativeUrl)) {
        Write-Warning 'Skipped a row with an empty ServerRelativeUrl.'
        continue
    }

    $exists = Get-PnPFile -Url $serverRelativeUrl -ErrorAction SilentlyContinue
    [pscustomobject]@{ Url=$serverRelativeUrl; Exists=[bool]$exists; Execute=$Execute }

    if ($Execute -and $exists -and $PSCmdlet.ShouldProcess($serverRelativeUrl, 'Remove SharePoint file')) {
        Remove-PnPFile -ServerRelativeUrl $serverRelativeUrl -Force
    }
}
