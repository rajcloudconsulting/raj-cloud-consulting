<#
.SYNOPSIS
    Test Azure Key Vault private connectivity

.DESCRIPTION
    Checks DNS resolution and TCP 443 reachability for supplied Key Vault DNS names without exposing any real vault names.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$VaultDnsName
)

foreach ($name in $VaultDnsName) {
    $dns = try { Resolve-DnsName -Name $name -ErrorAction Stop } catch { $null }
    $addresses = $dns | Where-Object Type -eq 'A' | Select-Object -ExpandProperty IPAddress

    $tcp = Test-NetConnection -ComputerName $name -Port 443 -WarningAction SilentlyContinue

    [pscustomobject]@{
        VaultDnsName = $name
        ResolvedAddresses = ($addresses -join ', ')
        Tcp443Reachable = $tcp.TcpTestSucceeded
        RemoteAddress = $tcp.RemoteAddress
    }
}
