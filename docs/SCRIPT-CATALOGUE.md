# Public Script Catalogue

This catalogue contains generic, sanitised examples that demonstrate experience across endpoint management, Azure, Microsoft 365, security, networking and operations.

**Total scripts: 23**

## Avd

### [Report FSLogix configuration and service health](../scripts/avd/Get-FSLogixHealth.ps1)
Reports FSLogix service state and selected non-secret configuration values useful for troubleshooting profile-container issues.

Tags: AVD, FSLogix, Health

### [Test Azure Virtual Desktop image readiness](../scripts/avd/Test-AVDImageReadiness.ps1)
Performs local checks commonly used before sealing an AVD image, including pending restart, BitLocker, profile, Teams and FSLogix indicators.

Tags: AVD, Image, FSLogix, Teams

## Azure

### [Audit Azure resource tag compliance](../scripts/azure/Get-AzureResourceTagCompliance.ps1)
Uses the Az module to report resources missing one or more required governance tags. No tenant or subscription value is embedded.

Tags: Azure, Governance, Tags, Az PowerShell

### [Create an Azure VM operational report](../scripts/azure/Get-AzureVMOperationalReport.ps1)
Produces a generic VM inventory including power state, size, operating system and identity type using the Az module.

Tags: Azure, VM, Inventory, Az PowerShell

### [Test Azure Key Vault private connectivity](../scripts/azure/Test-KeyVaultPrivateConnectivity.ps1)
Checks DNS resolution and TCP 443 reachability for supplied Key Vault DNS names without exposing any real vault names.

Tags: Azure, Key Vault, Private Endpoint, Connectivity

## Endpoint

### [Collect Intune Management Extension diagnostics](../scripts/endpoint/Get-IntuneManagementExtensionDiagnostics.ps1)
Collects service status, recent relevant event log entries and log-file metadata without copying tenant-specific log contents.

Tags: Intune, Diagnostics, Endpoint

## Exchange

### [Audit Exchange Online connectors](../scripts/exchange/Get-ExchangeConnectorAudit.ps1)
Reports inbound and outbound connector configuration after the administrator connects to Exchange Online.

Tags: Exchange Online, M365, Audit

## Hardware

### [Detect HP BIOS setup password state](../scripts/hardware/Detect-HPBiosPasswordState.ps1)
Checks whether the HP Client Management Script Library is present and reports only whether a setup password is configured; it never reads or exposes the password.

Tags: HP, BIOS, Intune, Detection

## Intune

### [Detect Windows and Microsoft Edge Copilot configuration](../scripts/intune/Detect-WindowsAndEdgeCopilot.ps1)
Intune detection script that checks Windows Copilot and Microsoft Edge Copilot-related policy values.

Tags: Intune, Detection, Copilot, Edge

### [Detect a pending Windows restart](../scripts/intune/Detect-PendingReboot.ps1)
Intune detection script for common component servicing, Windows Update and pending file rename restart indicators.

Tags: Intune, Windows, Detection

### [Disable Windows and Microsoft Edge Copilot](../scripts/intune/Remediate-WindowsAndEdgeCopilot.ps1)
Removes supported Copilot packages where present and applies machine/user policy settings for Windows and Microsoft Edge.

Tags: Intune, Windows, Edge, Remediation

### [Set the Windows time zone](../scripts/intune/Remediate-TimeZone.ps1)
Parameterised remediation for configuring a Windows time zone and validating the resulting setting.

Tags: Intune, Windows, Remediation

## M365

### [Inventory Microsoft 365 application components](../scripts/m365/Get-Microsoft365AppInventory.ps1)
Inventories selected Microsoft 365, Teams, OneDrive and WebView2 installation information from standard local sources.

Tags: M365, Inventory, Teams, Office

### [Test the Teams Outlook add-in](../scripts/m365/Test-TeamsOutlookAddin.ps1)
Checks common registry and installation indicators for the Microsoft Teams meeting add-in used by Outlook.

Tags: Teams, Outlook, M365, Detection

## Network

### [Audit Windows authenticated-scan prerequisites](../scripts/network/Test-NessusWindowsPrerequisites.ps1)
Audits services, firewall rules and administrative shares commonly required for authenticated Windows vulnerability scanning.

Tags: Security, Nessus, Network, Audit

### [Test TCP and UDP connectivity](../scripts/network/Test-TcpUdpConnectivity.ps1)
Parameterised connectivity test suitable for Event Hubs, syslog, proxy or other endpoint validation without embedded organisation-specific addresses.

Tags: Network, TCP, UDP, Troubleshooting

### [Validate private endpoint DNS resolution](../scripts/network/Test-PrivateEndpointDns.ps1)
Resolves a supplied hostname, reports aliases and addresses, and optionally verifies that resolved addresses fall inside expected private CIDR prefixes.

Tags: Azure, DNS, Private Endpoint, Network

## Operations

### [Register startup and shutdown wrapper tasks](../scripts/operations/Register-StartupShutdownTasks.ps1)
Creates generic scheduled tasks for a startup script and an event-triggered shutdown wrapper. Paths are supplied as parameters.

Tags: Windows, Scheduled Task, Operations

### [Report Splunk Universal Forwarder health](../scripts/operations/Get-SplunkForwarderHealth.ps1)
Reports service state, executable version where available and selected local configuration-file metadata without revealing configuration contents.

Tags: Splunk, Operations, Health

## Security

### [Report Microsoft Defender endpoint health](../scripts/security/Test-DefenderHealth.ps1)
Reports Defender service, antivirus status and selected preference values using built-in Defender cmdlets.

Tags: Defender, Security, Health

### [Validate a Defender indicator CSV](../scripts/security/Test-DefenderIOCImportCsv.ps1)
Validates indicator type, value, action and severity fields before a CSV is used in an administrative import workflow.

Tags: Defender, IOC, CSV, Validation

## Sharepoint

### [Plan SharePoint file deletion from CSV](../scripts/sharepoint/Remove-SharePointFilesFromCsv-DryRun.ps1)
Validates a CSV file list and defaults to dry-run behaviour. Actual deletion requires an explicit switch and an established PnP connection.

Tags: SharePoint, PnP PowerShell, Dry Run

## Teams

### [Audit Teams compliance recording configuration](../scripts/teams/Get-TeamsComplianceRecordingAudit.ps1)
Reports Teams compliance recording policies and paired application metadata after connecting to Microsoft Teams.

Tags: Teams, Compliance Recording, Audit
