function Set-PreviousLocation {
	[CmdletBinding()] param (
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.PathInfo[]] $DirectoryHistory = $Global:DirectoryHistory
	)
	if ( $DirectoryHistory.Count -Gt 1 ) {
		Set-Location $DirectoryHistory[$DirectoryHistory.Count - 2]
	}
}
Set-Alias cd- Set-PreviousLocation
