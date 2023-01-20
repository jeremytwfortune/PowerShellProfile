function Update-EnvironmentPath {
	[CmdletBinding()]
	param()

	$currentPaths = $Env:Path -split ";"
	$systemPaths = "User", "Machine" |
		ForEach-Object {
			[System.Environment]::GetEnvironmentVariable("Path", $_) -split ";"
		}

	$paths = $systemPaths + $currentPaths |
		Where-Object Length -GT 0 |
		Select-Object -Unique
	$Env:Path = $paths -join ";"
}