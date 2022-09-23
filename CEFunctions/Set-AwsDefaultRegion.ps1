function Set-AwsDefaultRegion {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[string]$Region
	)

	Write-Verbose "Setting AWS default region to $Region"
	$Env:AWS_DEFAULT_REGION = $Region
	$Env:AWS_REGION = $Region

	Set-DefaultAWSRegion -Region $Region -Scope Global
}

Set-Alias -Name sadr -Value Set-AwsDefaultRegion -Scope Global