function Copy-CeHostedPasswordToClipboard {
	Get-Secret "Hosted" |
		ConvertFrom-SecureString -AsPlainText |
		Set-Clipboard
}

Set-Alias hpw Copy-CeHostedPasswordToClipboard
