function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string] $TokenCode,

		[Parameter()]
		[System.EnvironmentVariableTarget] $Environment = [System.EnvironmentVariableTarget]::Process,

		[Parameter()]
		[string] $SerialNumber = "arn:aws:iam::174627156110:mfa/jeremy",

		[Parameter()]
		[switch] $PassThru
	)

	$token = Get-STSSessionToken -SerialNumber $SerialNumber -TokenCode $TokenCode

	[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", $token.AccessKeyId, $Environment)
	[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", $token.SecretAccessKey, $Environment)
	[Environment]::SetEnvironmentVariable("AWS_SESSION_TOKEN", $token.SessionToken, $Environment)

	if ($PassThru) {
		$token
	}
}