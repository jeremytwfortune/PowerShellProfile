function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[ValidateNotNullOrEmpty()]
		[string] $TokenCode = (Read-Host "Token Code"),

		[Parameter()]
		[System.EnvironmentVariableTarget] $Environment = [System.EnvironmentVariableTarget]::Process,

		[Parameter()]
		[string] $SerialNumber = "arn:aws:iam::174627156110:mfa/jeremy",

		[Parameter()]
		[System.Management.Automation.Runspaces.PSSession] $Session,

		[Parameter()]
		[switch] $PassThru
	)

	$token = Get-STSSessionToken -SerialNumber $SerialNumber -TokenCode $TokenCode

	if ($Session) {
		Write-Verbose "Writing to remote host $($Session.ComputerName)"
		Invoke-Command `
			-Session $Session `
			-ArgumentList $token, $Environment `
			-ScriptBlock {
				param($Token, $Environment)
				Write-Verbose "Setting AWS_ACCESS_KEY_ID to $($Token.AccessKeyId) for $Environment"
				[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", $Token.AccessKeyId, $Environment)
				Write-Verbose "Setting AWS_SECRET_ACCESS_KEY to $($Token.SecretAccessKey) for $Environment"
				[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", $Token.SecretAccessKey, $Environment)
				Write-Verbose "Setting AWS_SESSION_TOKEN to $($Token.SessionToken) for $Environment"
				[Environment]::SetEnvironmentVariable("AWS_SESSION_TOKEN", $Token.SessionToken, $Environment)
			}
	} else {
		Write-Verbose "Setting AWS_ACCESS_KEY_ID to $($Token.AccessKeyId) for $Environment"
		[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", $Token.AccessKeyId, $Environment)
		Write-Verbose "Setting AWS_SECRET_ACCESS_KEY to $($Token.SecretAccessKey) for $Environment"
		[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", $Token.SecretAccessKey, $Environment)
		Write-Verbose "Setting AWS_SESSION_TOKEN to $($Token.SessionToken) for $Environment"
		[Environment]::SetEnvironmentVariable("AWS_SESSION_TOKEN", $Token.SessionToken, $Environment)
	}

	if ($PassThru) {
		$token
	}
}