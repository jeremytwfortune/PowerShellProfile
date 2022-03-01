function Set-ProgetEnvironment {
	[CmdletBinding()]
	param()

	$opBuildServerEntry = Get-Secret "BuildServer"
	$Env:PROGET_USERNAME = $opBuildServerEntry.UserName
	$Env:PROGET_PASSWORD = $opBuildServerEntry.GetNetworkCredential().Password
}
