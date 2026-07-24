<#
.SYNOPSIS
    Detect HP BIOS setup password state

.DESCRIPTION
    Checks whether the HP Client Management Script Library is present and reports only whether a setup password is configured; it never reads or exposes the password.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

if (-not (Get-Command Get-HPBIOSSetupPasswordIsSet -ErrorAction SilentlyContinue)) {
    Write-Output 'Non-compliant: HP Client Management Script Library is not installed.'
    exit 1
}

try {
    $isSet = Get-HPBIOSSetupPasswordIsSet
    if ($isSet) {
        Write-Output 'Compliant: BIOS setup password is configured.'
        exit 0
    }

    Write-Output 'Non-compliant: BIOS setup password is not configured.'
    exit 1
} catch {
    Write-Error "Unable to query BIOS password state: $($_.Exception.Message)"
    exit 1
}
