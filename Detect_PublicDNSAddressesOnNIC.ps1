[bool]$remediationNeeded = $false

# Get all network interfaces from the registry
$interfaces = Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"

foreach ($interface in $interfaces) {
    # Get the DNS server addresses
    $dnsServers = Get-ItemProperty -Path $interface.PSPath -Name "NameServer" -ErrorAction SilentlyContinue
    # Get the interface name
    $dhcpServer = Get-ItemProperty -Path $interface.PSPath -Name "DhcpServer" -ErrorAction SilentlyContinue
    if ($dnsServers.NameServer -like "*1.1.*" -or $dnsServers.NameServer -like "*8.8.*" -or $dnsServers.NameServer -like "*192.168.*" -or $dnsServers.NameServer -like "*208.67.*" -or $dnsServers.NameServer -like "*9.9.*" -or $dnsServers.NameServer -like "*149.112.*") {
        Write-Output "Public DNS name servers detected on interface $($interface.PSChildName)"
        Write-Output "DNS Servers: $($dnsServers.NameServer)"
        $remediationNeeded = $true
    } else {
        Write-Output "Interface: $($interface.PSChildName)"
        Write-Output "DNS Servers: Automatically configured"
    }
    Write-Output "-----------------------------------"
}

if ($remediationNeeded) {
    Write-Host "Remediation Needed. Exiting with code 1."
    Exit 1
} else {
    Write-Host "No remediation needed. Exiting with code 0."
    Exit 0
}