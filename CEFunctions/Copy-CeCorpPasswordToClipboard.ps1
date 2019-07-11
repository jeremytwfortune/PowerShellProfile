function Copy-CeCorpPasswordToClipboard {
	$Global:CredentialStore.CeCorp.GetNetworkCredential().Password | Set-Clipboard
}

Set-Alias pw Copy-CeCorpPasswordToClipboard
