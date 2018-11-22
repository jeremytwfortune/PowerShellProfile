function Reset-Rainmeter {
	$baseInstallDirectory = "C:\Program Files\Rainmeter"
	$rainmeter = ( Get-ChildItem -Recurse $baseInstallDirectory "Rainmeter.exe" ).FullName
	& "$rainmeter" '!RefreshApp'
}
