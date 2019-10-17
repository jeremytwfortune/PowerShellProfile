Set-PSReadlineOption -BellStyle None
Set-PSReadlineKeyHandler -Key Tab -Functio Complete
Set-PSReadlineKeyHandler -Key "Ctrl+d" -Functio DeleteCharOrExit

Import-Module CredentialManager

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

$Work = "$Home\Work"
$Desk = "$Home\Desktop"
$Repos = "$Home\Repos"
$Drive = "$Home\Google Drive"
$Ssms = "C:\Program Files (x86)\Microsoft SQL Server\130\Tools\Binn\ManagementStudio\Ssms.exe"

$Env:Path = "$Env:Path;C:\Program Files\Git\usr\bin"

Get-ChildItem "$(Split-Path $PROFILE)\Functions" | %{
	. $_.FullName
}

$Global:CredentialStore = @{ Tokens = @{} }
if ( $oAuthCredential = Get-StoredCredential -Type Generic -WarningAction SilentlyContinue -Target "api.github.com/oauth" ) {
	$Global:CredentialStore.Tokens.GitHubOAuthToken = $oAuthCredential.GetNetworkCredential().Password
}

function Invoke-GitStatus { git status }; Set-Alias gits Invoke-GitStatus

Import-Module posh-git -Force *>$Null

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

. "$(Split-Path $PROFILE)\prompt.ps1"
Set-Location $Home
