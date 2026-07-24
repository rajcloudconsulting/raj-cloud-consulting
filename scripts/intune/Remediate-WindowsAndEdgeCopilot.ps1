<#
.SYNOPSIS
    Disable Windows and Microsoft Edge Copilot

.DESCRIPTION
    Removes supported Copilot packages where present and applies machine/user policy settings for Windows and Microsoft Edge.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

<#
.SYNOPSIS
    Removes Microsoft Copilot and disables Copilot in Windows
    and Microsoft 365 Apps.

.DESCRIPTION
    Intended for Microsoft Intune Remediations.
    Run as SYSTEM in 64-bit PowerShell.
#>

$ErrorActionPreference = "Continue"
$Results = [System.Collections.Generic.List[string]]::new()

function Set-RegistryDWORD {
    param (
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [int]$Value
    )

    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        New-ItemProperty `
            -Path $Path `
            -Name $Name `
            -PropertyType DWord `
            -Value $Value `
            -Force | Out-Null

        return $true
    }
    catch {
        $Results.Add(
            "Failed registry setting $Path\$Name : $($_.Exception.Message)"
        )
        return $false
    }
}

function Configure-UserHive {
    param (
        [Parameter(Mandatory)]
        [string]$HiveRoot
    )

    # Disable Windows Copilot
    $WindowsCopilotPath =
        "$HiveRoot\Software\Policies\Microsoft\Windows\WindowsCopilot"

    Set-RegistryDWORD `
        -Path $WindowsCopilotPath `
        -Name "TurnOffWindowsCopilot" `
        -Value 1 | Out-Null

    # Disable Office connected experiences that analyse content.
    # This disables Microsoft 365 Copilot in Word, Excel,
    # PowerPoint, Outlook and OneNote.
    $OfficePrivacyPath =
        "$HiveRoot\Software\Policies\Microsoft\Office\16.0\Common\Privacy"

    Set-RegistryDWORD `
        -Path $OfficePrivacyPath `
        -Name "UserContentDisabled" `
        -Value 2 | Out-Null

    # Prevent personal/consumer Copilot account access where supported
    $OfficeCommonPath =
        "$HiveRoot\Software\Policies\Microsoft\Office\16.0\Common"

    Set-RegistryDWORD `
        -Path $OfficeCommonPath `
        -Name "SignInOptions" `
        -Value 3 | Out-Null
}

# ------------------------------------------------------------
# 1. Remove installed Microsoft Copilot Appx packages
# ------------------------------------------------------------

try {
    $InstalledPackages = Get-AppxPackage -AllUsers |
        Where-Object {
            $_.Name -match "Copilot" -or
            $_.PackageFamilyName -match "Copilot"
        }

    foreach ($Package in $InstalledPackages) {
        try {
            Remove-AppxPackage `
                -Package $Package.PackageFullName `
                -AllUsers `
                -ErrorAction Stop

            $Results.Add("Removed installed package: $($Package.Name)")
        }
        catch {
            $Results.Add(
                "Unable to remove package $($Package.Name): " +
                "$($_.Exception.Message)"
            )
        }
    }
}
catch {
    $Results.Add(
        "Failed while checking installed packages: $($_.Exception.Message)"
    )
}

# ------------------------------------------------------------
# 2. Remove provisioned Copilot packages
# ------------------------------------------------------------

try {
    $ProvisionedPackages = Get-AppxProvisionedPackage -Online |
        Where-Object {
            $_.DisplayName -match "Copilot" -or
            $_.PackageName -match "Copilot"
        }

    foreach ($Package in $ProvisionedPackages) {
        try {
            Remove-AppxProvisionedPackage `
                -Online `
                -PackageName $Package.PackageName `
                -AllUsers `
                -ErrorAction Stop | Out-Null

            $Results.Add(
                "Removed provisioned package: $($Package.DisplayName)"
            )
        }
        catch {
            $Results.Add(
                "Unable to remove provisioned package " +
                "$($Package.DisplayName): $($_.Exception.Message)"
            )
        }
    }
}
catch {
    $Results.Add(
        "Failed while checking provisioned packages: " +
        "$($_.Exception.Message)"
    )
}

# ------------------------------------------------------------
# 3. Apply machine-level Windows Copilot policy
# ------------------------------------------------------------

$MachineWindowsCopilotPath =
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"

Set-RegistryDWORD `
    -Path $MachineWindowsCopilotPath `
    -Name "TurnOffWindowsCopilot" `
    -Value 1 | Out-Null


# ------------------------------------------------------------
# 4. Disable Copilot and hide the Copilot icon in Microsoft Edge
# ------------------------------------------------------------

$EdgePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"

# Completely disable the Copilot feature in Microsoft Edge.
Set-RegistryDWORD `
    -Path $EdgePolicyPath `
    -Name "EdgeCopilotEnabled" `
    -Value 0 | Out-Null

# Hide the Microsoft 365 Copilot Chat toolbar icon in newer Edge versions.
Set-RegistryDWORD `
    -Path $EdgePolicyPath `
    -Name "Microsoft365CopilotChatIconEnabled" `
    -Value 0 | Out-Null

# Hide the Edge sidebar, which also removes Copilot from the sidebar.
Set-RegistryDWORD `
    -Path $EdgePolicyPath `
    -Name "HubsSidebarEnabled" `
    -Value 0 | Out-Null

# Prevent the standalone Edge sidebar from being activated.
Set-RegistryDWORD `
    -Path $EdgePolicyPath `
    -Name "StandaloneHubsSidebarEnabled" `
    -Value 0 | Out-Null

$Results.Add("Disabled Microsoft Edge Copilot and hid the Copilot/sidebar icons")

# ------------------------------------------------------------
# 5. Configure currently loaded users
# ------------------------------------------------------------

$LoadedUserSIDs = Get-ChildItem Registry::HKEY_USERS |
    Where-Object {
        $_.PSChildName -match "^S-1-5-21-" -and
        $_.PSChildName -notmatch "_Classes$"
    } |
    Select-Object -ExpandProperty PSChildName

foreach ($SID in $LoadedUserSIDs) {
    Configure-UserHive `
        -HiveRoot "Registry::HKEY_USERS\$SID"

    $Results.Add("Configured loaded user: $SID")
}

# ------------------------------------------------------------
# 6. Configure existing unloaded user profiles
# ------------------------------------------------------------

$Profiles = Get-CimInstance Win32_UserProfile |
    Where-Object {
        -not $_.Special -and
        $_.LocalPath -and
        (Test-Path "$($_.LocalPath)\NTUSER.DAT")
    }

foreach ($Profile in $Profiles) {

    $SID = $Profile.SID

    # Skip profiles that are already loaded
    if (Test-Path "Registry::HKEY_USERS\$SID") {
        continue
    }

    $HiveName = "CopilotTemp_$($SID -replace '-', '_')"
    $HiveFile = Join-Path $Profile.LocalPath "NTUSER.DAT"

    try {
        $LoadResult = & reg.exe load "HKU\$HiveName" "$HiveFile" 2>&1

        if ($LASTEXITCODE -eq 0) {
            Configure-UserHive `
                -HiveRoot "Registry::HKEY_USERS\$HiveName"

            [gc]::Collect()
            [gc]::WaitForPendingFinalizers()

            & reg.exe unload "HKU\$HiveName" | Out-Null

            $Results.Add("Configured profile: $($Profile.LocalPath)")
        }
        else {
            $Results.Add(
                "Unable to load profile $($Profile.LocalPath): $LoadResult"
            )
        }
    }
    catch {
        $Results.Add(
            "Failed profile $($Profile.LocalPath): $($_.Exception.Message)"
        )

        & reg.exe unload "HKU\$HiveName" 2>$null | Out-Null
    }
}

# ------------------------------------------------------------
# 7. Configure the default profile for future users
# ------------------------------------------------------------

$DefaultHiveFile = "C:\Users\Default\NTUSER.DAT"
$DefaultHiveName = "CopilotDefaultUser"

if (Test-Path $DefaultHiveFile) {
    try {
        & reg.exe load "HKU\$DefaultHiveName" "$DefaultHiveFile" |
            Out-Null

        if ($LASTEXITCODE -eq 0) {
            Configure-UserHive `
                -HiveRoot "Registry::HKEY_USERS\$DefaultHiveName"

            [gc]::Collect()
            [gc]::WaitForPendingFinalizers()

            & reg.exe unload "HKU\$DefaultHiveName" | Out-Null

            $Results.Add("Configured Windows default user profile")
        }
    }
    catch {
        $Results.Add(
            "Failed to configure default profile: $($_.Exception.Message)"
        )

        & reg.exe unload "HKU\$DefaultHiveName" 2>$null | Out-Null
    }
}

# ------------------------------------------------------------
# 8. Close Copilot process if running
# ------------------------------------------------------------

Get-Process |
    Where-Object {
        $_.ProcessName -match "Copilot"
    } |
    Stop-Process -Force -ErrorAction SilentlyContinue

# ------------------------------------------------------------
# Result
# ------------------------------------------------------------

Write-Output ($Results -join " | ")
exit 0
