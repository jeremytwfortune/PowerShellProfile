function Copy-CeCorpPasswordToClipboard {
	Get-Secret "Corp" | Set-Clipboard
}

Set-Alias pw Copy-CeCorpPasswordToClipboard
