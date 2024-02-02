function Import-GsudoModule {
	param()

	if (-not $IsWindows) {
		return
	}

	$toolsPath = "C:\tools\gsudo\Current"
	$programFilesPath = "${env:ProgramFiles}\gsudo"

	if (Test-Path $toolsPath) {
		Import-Module "$toolsPath\gsudoModule.psd1"
		return
	}

	Get-ChildItem $programFilesPath |
		Sort-Object CreationTime -Descending |
		Select-Object -First 1 -ExpandProperty FullName |
		Get-ChildItem |
		Where-Object { $_.Name -eq "gsudoModule.psd1" } |
		Import-Module
}
