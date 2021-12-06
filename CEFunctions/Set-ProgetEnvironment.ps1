function Set-ProgetEnvironment {
	[CmdletBinding()]
	param()

	$opBuildServerResponse = op get item buildserver@corp 2>&1
	if ($opBuildServerResponse -like '*[ERROR]*') {
		Write-Verbose "No active login for 1p; Signing in"
		$Env:OP_SESSION_careevolution = Get-Secret "1Password" |
			ConvertFrom-SecureString -AsPlainText |
			op signin careevolution --raw
		$opBuildServerResponse = op get item buildserver@corp
	}

	$opBuildServerEntry = $opBuildServerResponse | ConvertFrom-Json
	$Env:PROGET_USERNAME = $opBuildServerEntry.details.fields |
		Where-Object name -eq "username" |
		Select-Object -ExpandProperty value
	$Env:PROGET_PASSWORD = $opBuildServerEntry.details.fields |
		Where-Object name -eq "password" |
		Select-Object -ExpandProperty value
}
