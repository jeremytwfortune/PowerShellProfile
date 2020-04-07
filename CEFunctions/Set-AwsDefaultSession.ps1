#Requires -Modules AWS.Tools.SecurityToken

function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[ValidateSet("Corp", "Pep")]
		[string] $Environment,

		[Parameter()]
		[string] $TokenCode = (Read-Host "Token Code"),

		[Parameter()]
		[ValidateSet("Sandbox")]
		[string] $RoleName
	)

	function Set-EnvironmentFromToken {
		param($token)

		$Env:AWS_ACCESS_KEY_ID = $token.AccessKeyId
		$Env:AWS_SECRET_ACCESS_KEY = $token.SecretAccessKey
		$Env:AWS_SESSION_TOKEN = $token.SessionToken
		Set-AWSCredential `
			-AccessKey $Env:AWS_ACCESS_KEY_ID `
			-SecretKey $Env:AWS_SECRET_ACCESS_KEY `
			-SessionToken $Env:AWS_SESSION_TOKEN
	}

	& $PSScriptRoot\Clear-AwsDefaultSession $Environment

	$stsSessionToken = Get-STSSessionToken -SerialNumber $Env:AWS_MFA_SERIAL -TokenCode $TokenCode
	Set-EnvironmentFromToken $stsSessionToken

	if (-Not $RoleName) { return }

	switch ($RoleName) {
		"Sandbox" { $roleArn = "arn:aws:iam::308326368506:role/ParentAccountAdministrator" }
	}

	$stsRole = Use-STSRole `
		-RoleArn $roleArn `
		-AccessKey $Env:AWS_ACCESS_KEY_ID `
		-SecretKey $Env:AWS_SECRET_ACCESS_KEY `
		-SessionToken $Env:AWS_SESSION_TOKEN `
		-RoleSessionName "${RoleName}Session"
	Set-EnvironmentFromToken $stsRole.Credentials
}