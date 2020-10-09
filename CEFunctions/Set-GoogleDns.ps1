function Set-GoogleDns {
	Get-DnsClientServerAddress "Ethernet 2" |
		Where-Object AddressFamily -eq 2 |
		Set-DnsClientServerAddress -ServerAddresses "8.8.4.4", "192.168.132.4"
}

Set-Alias sgd Set-GoogleDns
