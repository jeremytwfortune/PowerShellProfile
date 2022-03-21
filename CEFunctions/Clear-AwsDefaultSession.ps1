function Clear-AwsDefaultSession {
	[CmdletBinding()]
	param()

	Write-Verbose "Clearing AWS session"
	Clear-AWSCredential -Scope Global
	$Env:AWS_PROFILE = $null
}

Set-Alias -Name cads -Value Clear-AwsDefaultSession