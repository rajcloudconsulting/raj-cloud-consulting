<#
.SYNOPSIS
    Validate private endpoint DNS resolution

.DESCRIPTION
    Resolves a supplied hostname, reports aliases and addresses, and optionally verifies that resolved addresses fall inside expected private CIDR prefixes.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$Name,

    [string[]]$ExpectedPrefix = @('10.','172.16.','192.168.')
)

foreach ($dnsName in $Name) {
    try {
        $records = Resolve-DnsName -Name $dnsName -ErrorAction Stop
        $addresses = $records | Where-Object Type -in 'A','AAAA' | Select-Object -ExpandProperty IPAddress
        $aliases = $records | Where-Object Type -eq 'CNAME' | Select-Object -ExpandProperty NameHost

        [pscustomobject]@{
            Name = $dnsName
            Aliases = ($aliases -join ', ')
            Addresses = ($addresses -join ', ')
            ExpectedPrivatePrefix = [bool]($addresses | Where-Object {
                $address = $_
                $ExpectedPrefix | Where-Object { $address.StartsWith($_) }
            })
        }
    } catch {
        [pscustomobject]@{ Name=$dnsName; Error=$_.Exception.Message }
    }
}
