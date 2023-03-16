function Set-ProgetEnvironment {
	[CmdletBinding()]
	param()

	$opBuildServerEntry = Get-Secret "BuildServer"
	$Env:PROGET_USERNAME = $opBuildServerEntry.UserName
	$Env:PROGET_PASSWORD = $opBuildServerEntry.GetNetworkCredential().Password

	Remove-Item $Home/.netrc -Force
	New-Item $Home/.netrc -ItemType File -Force | Out-Null
	$netrc = New-Object System.IO.StreamWriter $Home/.netrc
	$netrc.WriteLine("machine proget.careevolution.com")
	$netrc.WriteLine("login $($opBuildServerEntry.UserName)")
	$netrc.WriteLine("password $($opBuildServerEntry.GetNetworkCredential().Password)")
	$netrc.Close()
}
