function Copy-CeCorpPasswordToClipboard {
	Get-Secret "Corp" |
		ConvertFrom-SecureString -AsPlainText |
		Set-Clipboard
}

Set-Alias pw Copy-CeCorpPasswordToClipboard
