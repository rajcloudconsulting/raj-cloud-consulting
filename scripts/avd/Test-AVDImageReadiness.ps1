<#
.SYNOPSIS
    Test Azure Virtual Desktop image readiness

.DESCRIPTION
    Performs local checks commonly used before sealing an AVD image, including pending restart, BitLocker, profile, Teams and FSLogix indicators.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding()]
param()

$results = [System.Collections.Generic.List[object]]::new()

function Add-Check($Name, $Status, $Detail) {
    $results.Add([pscustomobject]@{ Check=$Name; Status=$Status; Detail=$Detail })
}

$pending = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
Add-Check 'Pending restart' ($(if($pending){'Warning'}else{'Pass'})) ($(if($pending){'Restart indicated'}else{'None detected'}))

$bitLocker = if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {
    Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue
}
Add-Check 'BitLocker' ($(if($bitLocker.ProtectionStatus -eq 'On'){'Review'}else{'Pass'})) "$($bitLocker.ProtectionStatus)"

$fslogix = Get-Service -Name frxsvc -ErrorAction SilentlyContinue
Add-Check 'FSLogix service' ($(if($fslogix){'Pass'}else{'Info'})) ($(if($fslogix){$fslogix.Status}else{'Not installed'}))

$teams = Get-AppxPackage -AllUsers -Name MSTeams -ErrorAction SilentlyContinue
Add-Check 'New Teams package' ($(if($teams){'Pass'}else{'Review'})) ($(if($teams){$teams.Version}else{'Not detected'}))

$wvdFlag = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Name IsWVDEnvironment -ErrorAction SilentlyContinue
Add-Check 'Teams VDI flag' ($(if($wvdFlag -eq 1){'Pass'}else{'Review'})) "IsWVDEnvironment=$wvdFlag"

$results | Format-Table -AutoSize
if ($results.Status -contains 'Warning' -or $results.Status -contains 'Review') { exit 1 }
exit 0
