Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource None
Set-PSReadLineKeyHandler -Key Tab -Functio Complete
Set-PSReadLineKeyHandler -Key "Ctrl+d" -Functio DeleteCharOrExit

[Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"

$Work = "$Home\Work"
$Desk = "$Home\Desktop"
$Repos = "$Home\Repos"
$Drive = "G:\My Drive"

Get-ChildItem "$(Split-Path $PROFILE)\Functions" | % {
	. $_.FullName
}

$Env:Path = "$Env:Path;$Home\Documents\WindowsPowerShell\Scripts"
$Env:Path = "$Env:Path;C:\Program Files\Git\bin;C:\Program Files (x86)\GnuPG\bin\"
Update-EnvironmentPath

$Env:VIRTUAL_ENV_DISABLE_PROMPT = $True

$Global:CredentialStore = @{}

. "$(Split-Path $PROFILE)\CareEvolution.ps1"

function Invoke-GitStatus { git status }; Set-Alias gits Invoke-GitStatus

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

. "$(Split-Path $PROFILE)\prompt.ps1"

Set-Location $Home
