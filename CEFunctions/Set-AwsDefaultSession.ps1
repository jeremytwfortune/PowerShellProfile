function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string] $TokenCode,

		[Parameter()]
		[string] $SerialNumber = "arn:aws:iam::174627156110:mfa/jeremy",

		[Parameter()]
		[switch] $PassThru,

		[Parameter()]
		[switch] $System
	)

	$token = Get-STSSessionToken -SerialNumber $SerialNumber -TokenCode $TokenCode

	if ($System) {
		[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", $token.AccessKeyId, [System.EnvironmentVariableTarget]::User)
		[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", $token.SecretAccessKey, [System.EnvironmentVariableTarget]::User)
		[Environment]::SetEnvironmentVariable("AWS_SESSION_TOKEN", $token.SessionToken, [System.EnvironmentVariableTarget]::User)
	} else {
		$Env:AWS_ACCESS_KEY_ID = $token.AccessKeyId
		$Env:AWS_SECRET_ACCESS_KEY = $token.SecretAccessKey
		$Env:AWS_SESSION_TOKEN = $token.SessionToken
	}

	if ($PassThru) {
		$token
	}
}