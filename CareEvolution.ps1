$Env:OCTOPUS_SERVERURL = "https://octopus.careevolution.com"
$Env:OCTOPUS_APIKEY = $CredentialStore.Tokens.OctopusApiKey
$Global:CredentialStore.Tokens.OctopusApiKey = Get-Secret "OctopusApiKey"
$Global:CredentialStore.Tokens.Proget = Get-Secret "Proget"

$global:StoredAWSRegion = 'us-east-1'

$Global:CredentialStore.CeDownloader = New-Object PSCredential("CEDownloader", (Get-Secret "CEDownloader"))
$Global:CredentialStore.CeCorp = New-Object PSCredential("jeremy@corp", (Get-Secret "Corp"))
$Global:CredentialStore.CePep = New-Object PSCredential("jeremy.fortune@pep", (Get-Secret "Pep"))
$Global:CredentialStore.Ce = New-Object PSCredential("jeremy", (Get-Secret "Corp"))

$Global:Ge2cDeployment = @{
	WebClientTestDev = "$Repos\SecurityAndChangeControl\src\aws\sandbox\ge2c\environments\dev\deployments\webclienttestdev"
	MyFhrDev = "$Repos\SecurityAndChangeControl\src\aws\pep\qa\ge2c\environments\dev\deployments\myfhrdev"
	MyFhrProd = "$Repos\SecurityAndChangeControl\src\aws\pep\galileo-prod\ge2c\environments\prod\deployments\myfhrprod"
	TenantGroupTest = "$Repos\SecurityAndChangeControl\src\aws\galileo\ge2c\environments\integrationtest\deployments\tenantgrouptest"
	VidantTest = "$Repos\SecurityAndChangeControl\src\aws\galileo\ge2c\environments\integrationtest\deployments\vidanttest"
	CamdenHieTest = "$Repos\SecurityAndChangeControl\src\aws\galileo\ge2c\environments\integrationtest\deployments\CamdenHieTest"
	TenantGroupProd = "$Repos\SecurityAndChangeControl\src\aws\galileo\ge2c\environments\prod\deployments\tenantgroupprod"
	VidantProd = "$Repos\SecurityAndChangeControl\src\aws\galileo\ge2c\environments\prod\deployments\vidantprod"
	CamdenHie = "$Repos\SecurityAndChangeControl\src\aws\galileo\ge2c\environments\prod\deployments\camdenhie"
}

if ( Test-Path $Home\CeServers.json ){
  $Global:CeServers = Get-Content $Home\CeServers.json | ConvertFrom-Json
}

Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | %{
	. $_.FullName
}

Set-Alias tf terraform
Set-Alias tg terragrunt
