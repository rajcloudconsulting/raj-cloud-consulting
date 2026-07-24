<#
.SYNOPSIS
    Audit Teams compliance recording configuration

.DESCRIPTION
    Reports Teams compliance recording policies and paired application metadata after connecting to Microsoft Teams.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

if (-not (Get-Command Get-CsTeamsComplianceRecordingPolicy -ErrorAction SilentlyContinue)) {
    throw 'Connect to Microsoft Teams before running this script.'
}

Get-CsTeamsComplianceRecordingPolicy | ForEach-Object {
    [pscustomobject]@{
        Identity = $_.Identity
        Enabled = $_.Enabled
        Description = $_.Description
        PairedApplicationCount = @($_.ComplianceRecordingPairedApplications).Count
        RequiredBeforeMeetingJoin = $_.RequiredBeforeMeetingJoin
        RequiredDuringMeeting = $_.RequiredDuringMeeting
        RequiredBeforeCallEstablishment = $_.RequiredBeforeCallEstablishment
        RequiredDuringCall = $_.RequiredDuringCall
    }
} | Format-Table -AutoSize
