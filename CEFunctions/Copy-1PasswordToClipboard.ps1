function Copy-1PasswordPasswordToClipboard {
	Get-Secret "1Password" |
		ConvertFrom-SecureString -AsPlainText |
		Set-Clipboard
}

Set-Alias 1pw Copy-1PasswordPasswordToClipboard
