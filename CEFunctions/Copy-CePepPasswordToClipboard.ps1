function Copy-CePepPasswordToClipboard {
	$Global:CredentialStore.CePep.GetNetworkCredential().Password | Set-Clipboard
}

Set-Alias ppw Copy-CePepPasswordToClipboard
