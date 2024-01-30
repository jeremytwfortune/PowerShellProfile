Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource None
Set-PSReadLineKeyHandler -Key Tab -Functio Complete
Set-PSReadLineKeyHandler -Key "Ctrl+d" -Functio DeleteCharOrExit

[Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"

$WinHome = $IsWindows ? $Home : "/mnt/c/Users/$(wslvar USERNAME)"
$Desk = $IsWindows ? "$Home\Desktop" : "$WinHome/Desktop"
$Repos = $IsWindows ? "$Home\Repos" : "$WinHome/Repos"
$Drive = $IsWindows ? "G:\My Drive" : "/mnt/g/My Drive"

Get-ChildItem "$(Split-Path $PROFILE)\Functions" | % {
	. $_.FullName
}

$Env:Path = "$Env:Path;$Home\Documents\WindowsPowerShell\Scripts"
$Env:Path = "$Env:Path;C:\Program Files\Git\bin;C:\Program Files (x86)\GnuPG\bin\"
Update-EnvironmentPath

Import-GsudoModule

$Env:VIRTUAL_ENV_DISABLE_PROMPT = $True

. "$(Split-Path $PROFILE)\CareEvolution.ps1"

function Invoke-GitStatus { git status }; Set-Alias gits Invoke-GitStatus

. "$(Split-Path $PROFILE)\prompt.ps1"

Set-Location $Home
