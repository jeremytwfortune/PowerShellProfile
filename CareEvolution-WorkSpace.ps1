$Global:CredentialStore.Tokens.Proget = Get-Secret "Proget"

$global:StoredAWSRegion = 'us-east-1'

$Global:CredentialStore.CePep = New-Object PSCredential("jeremy.fortune@pep", (Get-Secret "Pep"))
$Global:CredentialStore.Ce = New-Object PSCredential("jeremy", (Get-Secret "Corp"))

if ( Test-Path $Home\CeServers.json ){
  $Global:CeServers = Get-Content $Home\CeServers.json | ConvertFrom-Json
}

Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | %{
	. $_.FullName
}

Set-ProgetEnvironment
