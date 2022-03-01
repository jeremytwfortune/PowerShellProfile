$global:StoredAWSRegion = 'us-east-1'

if ( Test-Path $Home\CeServers.json ){
	$Global:CeServers = Get-Content $Home\CeServers.json | ConvertFrom-Json
}

Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | %{
	. $_.FullName
}

$Global:CredentialStore.CePep = New-Object PSCredential("jeremy.fortune@pep", (Get-Secret "Pep"))
$Global:CredentialStore.CeHosted = New-Object PSCredential("jeremy.fortune@hosted", (Get-Secret "Hosted"))
