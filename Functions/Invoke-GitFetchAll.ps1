function Invoke-GitFetchAll {
	$remotes = git remote
	$unfetchables = @( "pushless" )
	$remotes | ? { $unfetchables -NotContains $_ } | % {
		Write-Host "Fetching $_"
		git fetch $_ --prune
	}
}
Set-Alias gitf Invoke-GitFetchAll
