<#
.SYNOPSIS
    Audit Azure resource tag compliance

.DESCRIPTION
    Uses the Az module to report resources missing one or more required governance tags. No tenant or subscription value is embedded.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding()]
param(
    [string[]]$RequiredTag = @('Environment','Owner','CostCentre'),
    [string]$SubscriptionId
)

if (-not (Get-Module -ListAvailable -Name Az.Resources)) {
    throw 'Az.Resources module is required.'
}

if ($SubscriptionId) {
    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
}

Get-AzResource | ForEach-Object {
    $missing = foreach ($tag in $RequiredTag) {
        if (-not $_.Tags -or -not $_.Tags.ContainsKey($tag) -or [string]::IsNullOrWhiteSpace($_.Tags[$tag])) {
            $tag
        }
    }

    [pscustomobject]@{
        ResourceGroup = $_.ResourceGroupName
        ResourceName = $_.Name
        ResourceType = $_.ResourceType
        MissingTags = ($missing -join ', ')
        Compliant = $missing.Count -eq 0
    }
} | Sort-Object Compliant, ResourceGroup, ResourceName
