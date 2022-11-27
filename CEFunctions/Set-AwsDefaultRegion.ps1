function Set-AwsDefaultRegion {
	[CmdletBinding()]
	param(
		[ValidateSet('us-east-1', 'us-east-2', 'us-west-1', 'us-west-2')]
		[Parameter(Mandatory)]
		[string]$Region
	)

	Write-Verbose "Setting AWS default region to $Region"
	$Env:AWS_DEFAULT_REGION = $Region
	$Env:AWS_REGION = $Region

	Set-DefaultAWSRegion -Region $Region -Scope Global
}

Set-Alias -Name sadr -Value Set-AwsDefaultRegion -Scope Global
