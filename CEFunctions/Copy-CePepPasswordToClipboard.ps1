function Copy-CePepPasswordToClipboard {
	Get-Secret "Pep" |
		ConvertFrom-SecureString -AsPlainText |
		Set-Clipboard
}

Set-Alias ppw Copy-CePepPasswordToClipboard
