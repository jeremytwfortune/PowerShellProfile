function Clear-AwsDefaultSession {
	[CmdletBinding()]
	param()

	Write-Verbose "Clearing AWS session"
	Clear-AWSCredential -Scope Global
	$Env:AWS_PROFILE = $null

	$defaultRegion = "us-east-1"

	$Env:AWS_DEFAULT_REGION = $defaultRegion
	$Env:AWS_REGION = $defaultRegion
	Set-DefaultAWSRegion -Region $defaultRegion -Scope Global
}

Set-Alias -Name cads -Value Clear-AwsDefaultSession