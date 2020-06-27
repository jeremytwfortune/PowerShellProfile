Set-PSReadlineOption -BellStyle None
Set-PSReadlineKeyHandler -Key Tab -Functio Complete
Set-PSReadlineKeyHandler -Key "Ctrl+d" -Functio DeleteCharOrExit

[Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"

$Work = "$Home\Work"
$Desk = "$Home\Desktop"
$Repos = "$Home\Repos"
$Drive = "$Home\Google Drive"

$Env:Path = "$Env:Path;C:\Program Files\Git\usr\bin"

Get-ChildItem "$(Split-Path $PROFILE)\Functions" | %{
	. $_.FullName
}

$Global:SecretKeys = @()
$Global:CredentialStore = @{ Tokens = @{} }
if ( $oAuthCredential = Get-Secret -Name "api.github.com/oauth" -AsPlainText ) {
	$Global:CredentialStore.Tokens.GitHubOAuthToken = $oAuthCredential
}

function Invoke-GitStatus { git status }; Set-Alias gits Invoke-GitStatus

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

. "$(Split-Path $PROFILE)\prompt.ps1"
Set-Location $Home
