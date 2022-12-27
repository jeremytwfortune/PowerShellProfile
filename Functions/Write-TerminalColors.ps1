function Write-TerminalColors {
	# from https://stackoverflow.com/questions/20541456/list-of-all-colors-available-for-powershell
	$colors = [enum]::GetValues([System.ConsoleColor])
	foreach ($bgcolor in $colors) {
		foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewline }
		Write-Host " on $bgcolor"
	}
}