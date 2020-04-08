#Requires -Modules Aws.Tools.Common

# Galileo parameters to simulate OD

$Env:GALILEO_REPO = "C:\Users\Jeremy\Repos\Galileo"
$Env:NARYA_REPO = "C:\Users\Jeremy\Repos\narya"

$Env:OCTOPUS_SERVERURL = "https://octopus.careevolution.com"
$Env:OCTOPUS_APIKEY = $CredentialStore.Tokens.OctopusApiKey
$Global:CredentialStore.Tokens.OctopusApiKey = Get-Secret "OctopusApiKey"
$Global:CredentialStore.Tokens.Proget = Get-Secret "Proget"

$global:StoredAWSRegion = 'us-east-1'
if ($awsCredential = Get-Secret "aws.amazon.com/iam/corp") {
	$Env:AWS_ACCESS_KEY_ID = $awsCredential.UserName
	$Env:AWS_SECRET_ACCESS_KEY = $awsCredential.GetNetworkCredential().Password
	$Env:AWS_MFA_SERIAL = "arn:aws:iam::174627156110:mfa/jeremy"
	Set-AWSCredential -AccessKey $Env:AWS_ACCESS_KEY_ID -SecretKey $Env:AWS_SECRET_ACCESS_KEY
}

$Global:CredentialStore.CeDownloader = New-Object PSCredential("CEDownloader", (Get-Secret "CEDownloader"))
$Global:CredentialStore.CeCorp = New-Object PSCredential("jeremy@corp", (Get-Secret "Corp"))
$Global:CredentialStore.CePep = New-Object PSCredential("jeremy.fortune@pep.careevolution.com", (Get-Secret "Pep"))
$Global:CredentialStore.Ce = New-Object PSCredential("jeremy", (Get-Secret "Corp"))

if ( Test-Path $Home\CeServers.json ){
  $Global:CeServers = Get-Content $Home\CeServers.json | ConvertFrom-Json
}

Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | %{
	. $_.FullName
}
