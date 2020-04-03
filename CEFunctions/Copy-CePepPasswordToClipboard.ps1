function Copy-CePepPasswordToClipboard {
	Get-Secret "Pep" | Set-Clipboard
}

Set-Alias ppw Copy-CePepPasswordToClipboard
