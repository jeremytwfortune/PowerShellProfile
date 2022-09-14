$global:StoredAWSRegion = 'us-east-1'

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
	CloverExternal = "$Repos\SecurityAndChangeControl\src\aws\galileo\ge2c\client-datamarts\clover"
	NjExternal = "$Repos\SecurityAndChangeControl\src\aws\galileo\ge2c\client-datamarts\nj"
	VidantExternal = "$Repos\SecurityAndChangeControl\src\aws\galileo\ge2c\client-datamarts\vidant"
}

if ( Test-Path $Home\CeServers.json ) {
	$Global:CeServers = Get-Content $Home\CeServers.json | ConvertFrom-Json
}

$Global:StoredAWSCredentialPromptColor = "Magenta"

Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | % {
	. $_.FullName
}

Set-Alias tf terraform
Set-Alias tg terragrunt
