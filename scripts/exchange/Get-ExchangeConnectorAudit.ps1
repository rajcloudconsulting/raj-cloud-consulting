<#
.SYNOPSIS
    Audit Exchange Online connectors

.DESCRIPTION
    Reports inbound and outbound connector configuration after the administrator connects to Exchange Online.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

if (-not (Get-Command Get-InboundConnector -ErrorAction SilentlyContinue)) {
    throw 'Connect to Exchange Online before running this script.'
}

$inbound = Get-InboundConnector | Select-Object Name, Enabled, ConnectorType, RequireTls, SenderDomains
$outbound = Get-OutboundConnector | Select-Object Name, Enabled, ConnectorType, UseMXRecord, SmartHosts, TlsSettings

[pscustomobject]@{
    GeneratedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    InboundConnectors = $inbound
    OutboundConnectors = $outbound
} | ConvertTo-Json -Depth 6
