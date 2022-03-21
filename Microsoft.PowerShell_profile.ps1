Set-PSReadlineOption -BellStyle None
Set-PSReadlineKeyHandler -Key Tab -Functio Complete
Set-PSReadlineKeyHandler -Key "Ctrl+d" -Functio DeleteCharOrExit

[Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"

$Work = "$Home\Work"
$Desk = "$Home\Desktop"
$Repos = "$Home\Repos"
$Drive = "$Home\Google Drive"

$Env:Path = "$Env:Path;C:\Program Files\Git\usr\bin"

$Env:VIRTUAL_ENV_DISABLE_PROMPT = $True

Get-ChildItem "$(Split-Path $PROFILE)\Functions" | %{
	. $_.FullName
}

$Global:CredentialStore = @{}

function Invoke-GitStatus { git status }; Set-Alias gits Invoke-GitStatus

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

. "$(Split-Path $PROFILE)\prompt.ps1"

$Global:Prompt = @(
	{"`n" | New-PromptText -ForegroundColor "#282C34"},
	{Write-PromptPath},
	{Write-PromptGitHead},
	# {"`t"},
	{Write-PromptPythonVenv},
	{Write-PromptAwsProfile},
	{"`n"},
	{"&int;" | New-PromptText -ForegroundColor "White" -BackgroundColor "#282C34"}
)

Set-PowerLinePrompt -HideErrors -PowerLineFont
Set-Location $Home
