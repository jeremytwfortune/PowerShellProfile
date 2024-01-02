function Import-GsudoModule {
	param()

	if (-not $IsWindows) {
		return
	}

	Get-ChildItem "${env:ProgramFiles}\gsudo" |
		Sort-Object CreationTime -Descending |
		Select-Object -First 1 -ExpandProperty FullName |
		Get-ChildItem |
		Where-Object { $_.Name -eq "gsudoModule.psd1" } |
		Import-Module
}
