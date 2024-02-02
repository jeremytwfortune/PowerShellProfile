Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | % {
	. $_.FullName
}

Set-AwsDefaultRegion -Region "us-east-1"

$Global:CredentialStore.CePep = New-Object PSCredential("jeremy.fortune@pep", (Get-Secret "Pep"))
$Global:CredentialStore.CeHosted = New-Object PSCredential("jeremy.fortune@hosted", (Get-Secret "Hosted"))
