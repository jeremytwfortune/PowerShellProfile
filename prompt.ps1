function Get-PromptShortPath {
	param (
		[string] $Path,
		[hashtable] $ShortcutDirectories = @{
			Home = $Home;
			Work = $Work;
			Desk = $Desk;
			Drive = $Drive;
			Repos = $Repos
		}
	)
	$shortcutPath = if ( $shortcuts = $ShortcutDirectories.GetEnumerator() | ? { "$Path*" -Like "$($_.Value)*" } ) {
		$shortcut = $shortcuts | Sort-Object -Property Value -Descending | Select-Object -First 1 # Hacky
		$Path -Replace [regex]::Escape("$($shortcut.Value)"), "$($shortcut.Name)"
	} else {
		$Path -Replace [regex]::Escape("Microsoft.PowerShell.Core\FileSystem::"), ""
	}

	if (($pathParts = $shortcutPath -split '\\').Count -gt 4) {
		return "$($pathParts[0])\...\$($pathParts[-2])\$($pathParts[-1])"
	}
	$shortcutPath
}

function Get-PromptStatusBackgroundColor {
	$status = @(git status --porcelain)
	if ( $status.Count -eq 0 ) { return [System.ConsoleColor]::DarkGreen }
	if ( $status -cmatch "^.[^\s]" ) { return [System.ConsoleColor]::DarkMagenta }
	[System.ConsoleColor]::DarkYellow
}

function Write-PromptAwsProfile {
	if ($Global:StoredAWSCredentials -And $Global:StoredAWSCredentials -ne "default") {
		$color = $Global:StoredAWSCredentialPromptColor ?? "Gray"
		$credentialName = $Global:StoredAWSCredentials.ToString()

		"$credentialName " | New-PromptText -ForegroundColor Black -BackgroundColor $color
	}
}

function Write-PromptGitHead {
	try {
		$insideRepo = git rev-parse --is-inside-work-tree
		if ( -Not ( $headReference = git symbolic-ref --short HEAD 2>$Null ) ) {
			$headReference = (git rev-parse HEAD 2>$Null).Substring(0, 8)
		}
		" $headReference" | New-PromptText -ForegroundColor Black -BackgroundColor (Get-PromptStatusBackgroundColor)
	} catch {}
}

function Write-PromptPath {
	"$(Get-PromptShortPath -Path (Get-Location))" | New-PromptText
}

function Write-PromptPythonVenv {
	if ($Env:VIRTUAL_ENV) {
		$venvName = $Env:VIRTUAL_ENV -split '\\' | Select-Object -Last 1
		"$venvName &#128013;" | New-PromptText -ForegroundColor Black -BackgroundColor Blue
	}
}
