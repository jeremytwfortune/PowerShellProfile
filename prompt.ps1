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
	}
 else {
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
		$credentialName = $Global:StoredAWSCredentials.ToString()

		$regionName = $Env:AWS_REGION ?? $Env:AWS_DEFAULT_REGION ?? ""

		"🧼 $credentialName ($regionName)" | New-PromptText -ForegroundColor Black -BackgroundColor Blue
	}
}

function Write-PromptGcpProfile {
	$default = Get-Content -Path "${env:APPDATA}/gcloud/configurations/config_default" -ErrorAction SilentlyContinue
	if (-Not $default) {
		return
	}
	$default = $default -replace '^\[core\]$', '' | ConvertFrom-StringData
	if (-not $default.account) {
		return
	}

	"☁️ $($default.project)" | New-PromptText -ForegroundColor Black -BackgroundColor Green
}

function Write-PromptGitHead {
	try {
		$insideRepo = git rev-parse --is-inside-work-tree
		if ( -Not ( $headReference = git symbolic-ref --short HEAD 2>$Null ) ) {
			$headReference = (git rev-parse HEAD 2>$Null).Substring(0, 8)
		}
		"  $headReference" | New-PromptText -ForegroundColor Black -BackgroundColor (Get-PromptStatusBackgroundColor)
	}
 catch {}
}

function Write-PromptPath {
	"📁 $(Get-PromptShortPath -Path (Get-Location))" | New-PromptText -BackgroundColor Cyan
}

function Write-PromptPythonVenv {
	if ($Env:VIRTUAL_ENV) {
		$venvName = $Env:VIRTUAL_ENV -split '\\' | Select-Object -Last 1
		"&#128013; $venvName" | New-PromptText -ForegroundColor Black -BackgroundColor Blue
	}
}

function Write-CharacterPrompt {
	"&int; " | New-PromptText
}

$Global:Prompt = @(
	{ "`n" | New-PromptText -ForegroundColor White },
	{ Write-PromptPath },
	{ Write-PromptGitHead },
	{ "`t" },
	{ Write-PromptPythonVenv },
	{ Write-PromptGcpProfile },
	{ Write-PromptAwsProfile },
	{ "`n" },
	{ Write-CharacterPrompt }
)

Set-PowerLinePrompt -HideErrors -PowerLineFont -Colors $Null, $Null
