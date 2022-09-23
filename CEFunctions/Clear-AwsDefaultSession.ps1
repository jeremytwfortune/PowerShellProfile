function Clear-AwsDefaultSession {
	[CmdletBinding()]
	param()

	Write-Verbose "Clearing AWS session"
	Clear-AWSCredential -Scope Global
	$Env:AWS_PROFILE = $null

	$Env:AWS_DEFAULT_REGION = $null
	$Env:AWS_REGION = $null
	Clear-DefaultAWSRegion -Scope Global
}

Set-Alias -Name cads -Value Clear-AwsDefaultSession