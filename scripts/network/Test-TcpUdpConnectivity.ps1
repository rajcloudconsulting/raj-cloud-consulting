<#
.SYNOPSIS
    Test TCP and UDP connectivity

.DESCRIPTION
    Parameterised connectivity test suitable for Event Hubs, syslog, proxy or other endpoint validation without embedded organisation-specific addresses.

.NOTES
    Raj Cloud Consulting public sample.
    Generic and sanitised: no employer, client, tenant, subscription, hostname,
    internal address, credential or production resource information is included.
    Test in a lab or controlled pilot before production deployment.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string[]]$ComputerName,

    [int[]]$TcpPort = @(443),

    [int[]]$UdpPort = @(),

    [int]$TimeoutMilliseconds = 4000
)

foreach ($target in $ComputerName) {
    foreach ($port in $TcpPort) {
        $tcp = [System.Net.Sockets.TcpClient]::new()
        try {
            $task = $tcp.ConnectAsync($target, $port)
            $connected = $task.Wait($TimeoutMilliseconds) -and $tcp.Connected
            [pscustomobject]@{ Target=$target; Protocol='TCP'; Port=$port; Reachable=$connected }
        } catch {
            [pscustomobject]@{ Target=$target; Protocol='TCP'; Port=$port; Reachable=$false; Error=$_.Exception.Message }
        } finally {
            $tcp.Dispose()
        }
    }

    foreach ($port in $UdpPort) {
        $udp = [System.Net.Sockets.UdpClient]::new()
        try {
            $udp.Client.SendTimeout = $TimeoutMilliseconds
            $udp.Connect($target, $port)
            $payload = [Text.Encoding]::UTF8.GetBytes('connectivity-test')
            [void]$udp.Send($payload, $payload.Length)
            [pscustomobject]@{ Target=$target; Protocol='UDP'; Port=$port; Reachable='Datagram sent; response not guaranteed' }
        } catch {
            [pscustomobject]@{ Target=$target; Protocol='UDP'; Port=$port; Reachable=$false; Error=$_.Exception.Message }
        } finally {
            $udp.Dispose()
        }
    }
}
