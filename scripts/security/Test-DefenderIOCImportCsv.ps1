<#
.SYNOPSIS
    Validate a Defender indicator CSV

.DESCRIPTION
    Validates indicator type, value, action and severity fields before a CSV is used in an administrative import workflow.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Path
)

$allowedTypes = 'IpAddress','Url','DomainName','FileSha256','FileSha1','CertificateThumbprint'
$allowedActions = 'Alert','Warn','Block execution','Block and remediate','Allow'
$allowedSeverity = 'Informational','Low','Medium','High'

$rows = Import-Csv -Path $Path
$errors = [System.Collections.Generic.List[string]]::new()

for ($i = 0; $i -lt $rows.Count; $i++) {
    $row = $rows[$i]
    $line = $i + 2

    if ($row.'Indicator Type' -notin $allowedTypes) { $errors.Add("Line $line: invalid indicator type") }
    if ([string]::IsNullOrWhiteSpace($row.'Indicator Value')) { $errors.Add("Line $line: indicator value is empty") }
    if ($row.Action -and $row.Action -notin $allowedActions) { $errors.Add("Line $line: invalid action") }
    if ($row.Severity -and $row.Severity -notin $allowedSeverity) { $errors.Add("Line $line: invalid severity") }

    if ($row.'Indicator Type' -eq 'FileSha256' -and $row.'Indicator Value' -notmatch '^[A-Fa-f0-9]{64}$') {
        $errors.Add("Line $line: SHA-256 value is not 64 hexadecimal characters")
    }
}

if ($errors.Count) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "Validated $($rows.Count) indicator rows."
