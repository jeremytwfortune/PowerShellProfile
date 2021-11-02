$Env:OCTOPUS_SERVERURL = "https://octopus.careevolution.com"
$Env:OCTOPUS_APIKEY = $CredentialStore.Tokens.OctopusApiKey
$Global:CredentialStore.Tokens.OctopusApiKey = Get-Secret "OctopusApiKey"
$Global:CredentialStore.Tokens.Proget = Get-Secret "Proget"

$global:StoredAWSRegion = 'us-east-1'

$Global:CredentialStore.CeDownloader = New-Object PSCredential("CEDownloader", (Get-Secret "CEDownloader"))
$Global:CredentialStore.CeCorp = New-Object PSCredential("jeremy@corp", (Get-Secret "Corp"))
$Global:CredentialStore.CePep = New-Object PSCredential("jeremy.fortune@pep", (Get-Secret "Pep"))
$Global:CredentialStore.Ce = New-Object PSCredential("jeremy", (Get-Secret "Corp"))

if ( Test-Path $Home\CeServers.json ){
  $Global:CeServers = Get-Content $Home\CeServers.json | ConvertFrom-Json
}

Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | %{
	. $_.FullName
}

Set-Alias tf terraform
Set-Alias tg terragrunt
