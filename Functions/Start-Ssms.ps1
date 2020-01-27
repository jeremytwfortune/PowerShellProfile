function Start-Ssms {
	[CmdletBinding()] param (
		[PSCredential] $Credential
	)
	$baseInstallDirectory = "C:\Program Files (x86)\Microsoft SQL Server"
	$ssms = Get-ChildItem -Recurse $baseInstallDirectory "Ssms.exe" |
		Sort-Object -Property LastWritetime |
		Select-Object -First 1 -ExpandProperty FullName
	if ( $Credential ) {
		Invoke-Expression "runas /netonly /user:$($Credential.Username) ""$ssms"""
	} else {
		& $ssms
	}
}
