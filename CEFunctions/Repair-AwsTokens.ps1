function Repair-AwsTokens {
	[CmdletBinding()]
	param()

	$locationData = "$Home\AwsAssumableRoles.txt"
	if ( -Not ( Test-Path $locationData -ErrorAction SilentlyContinue ) ) {
		throw "File '$locationData' cannot be found"
	}
	$roleNames = Get-Content $locationData | ConvertFrom-StringData

	Set-AwsDefaultSession Pep
	$roleNames.Keys | ForEach-Object { Set-AwsDefaultSession Corp $_ }

	Clear-AwsDefaultSession
}

Set-Alias -Name rat -Value Repair-AwsTokens