# Galileo parameters to simulate OD

$Env:GALILEO_REPO = "C:\Users\Jeremy\Repos\Galileo_Content"
$Env:NARYA_REPO = "C:\Users\Jeremy\Repos\narya"

Import-Module CE-PSModule -WarningAction SilentlyContinue
Import-Module Galileo.Cli

Set-CEEnv "C:\Users\Jeremy\Repos\Consumers\Deployments\WebClientTest.xml" -WarningAction SilentlyContinue
$Env:Path = "$Env:Path;$Repos\narya-tools\Packomatic\ntools\bin\Debug"

if ( $oAuthCredential = Get-StoredCredential -Type Generic -WarningAction SilentlyContinue -Target "api.octopus.careevolution.com" ) {
	$Global:CredentialStore.Tokens.OctopusApiKey = $oAuthCredential.GetNetworkCredential().Password
}
if ( $progetCredential = Get-StoredCredential -Type Generic -WarningAction SilentlyContinue -Target "proget.careevolution.com" ) {
	$Global:CredentialStore.Tokens.Proget = $progetCredential.GetNetworkCredential().Password
}
$Global:CredentialStore.Ce = Get-StoredCredential -Type Generic -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Target "download.careevolution.com"
$Global:CredentialStore.CeCorp = Get-StoredCredential -Type Generic -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Target "adfs.careevolution.com"
$Global:CredentialStore.Trinity = Get-StoredCredential -Type Generic -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Target "devidp.trinity-health.org"

$Env:B3POSH_URL = "https://b3.careevolution.com"
$Env:B3POSH_API_KEY = ( Get-StoredCredential -Type Generic -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Target "b3.careevolution.com" ).GetNetworkCredential().Password
$Env:OCTOPUS_SERVERURL = "https://octopus.careevolution.com"
$Env:OCTOPUS_APIKEY = $CredentialStore.Tokens.OctopusApiKey

if ( Test-Path $Home\CeServers.json ){
  $Global:CeServers = Get-Content $Home\CeServers.json | ConvertFrom-Json
}

Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" |
	%{
		. $_.FullName
	}

function Copy-CeCorpPasswordToClipboard { $Global:CredentialStore.CeCorp.GetNetworkCredential().Password | Set-Clipboard }; Set-Alias pw Copy-CeCorpPasswordToClipboard
