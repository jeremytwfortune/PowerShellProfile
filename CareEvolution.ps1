Import-Module AWS.Tools.SSO
Import-Module AWS.Tools.SSOOIDC

Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | % {
	. $_.FullName
}

Set-AwsDefaultRegion -Region "us-east-1"

Set-Alias tf terraform
Set-Alias tg terragrunt
