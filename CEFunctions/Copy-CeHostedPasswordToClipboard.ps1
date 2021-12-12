function Copy-CePepPasswordToClipboard {
	Get-Secret "Hosted" |
		ConvertFrom-SecureString -AsPlainText |
		Set-Clipboard
}

Set-Alias hpw Copy-CePepPasswordToClipboard
