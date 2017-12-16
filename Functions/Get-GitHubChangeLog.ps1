function Get-GitHubChangeLog {
	Param(
		[Parameter( Mandatory = $True )]
		[string]$CommitRange,

		[Parameter( Mandatory = $True )]
		[string]$OAuthToken,

		[Parameter( Mandatory = $True )]
		[string]$RepositoryName
	)

	function Get-RemainingSearches
	{
		$Response = Invoke-GitHubApiQuery -OAuthToken $OAuthToken -Query "rate_limit" |
			Select-Object -ExpandProperty "Content" |
			ConvertFrom-Json
		$Response.Resources.search.remaining
	}

	$ChangeLog = @()
	$Commits = git log $CommitRange --pretty="%H"
	$Commits |
		%{
			Write-Progress -Id 1 -Activity "Querying API" -CurrentOperation "Commit: $_" -PercentComplete (100 * $Commits.IndexOf( $_ ) / $Commits.Count)
			Try
			{
				$Response = (
					Invoke-GitHubApiQuery -OAuthToken $OAuthToken -Headers @{ "Accept" = "application/vnd.github.cloak-preview" } -Query "search/issues?q=repo:$RepositoryName+hash:$_" |
					Select-Object -ExpandProperty "Content" |
					ConvertFrom-Json
				)
			}
			Catch [System.Net.WebException]
			{
				Write-Host $Error[0].ErrorDetails.Message
				Break
			}

			if ( $Response.total_count -Eq 0 )
			{
				$CommitTitle = git log -1 --pretty="%s" $_
				$CommitAuthorName = git log -1 --pretty="%an" $_
				$Commit = git log -1 --pretty="%h" $_
				$ChangeLog += New-Object -Type PSObject -Property @{ "Title" = "$CommitTitle"; "Type" = "Commit"; "User" = "$CommitAuthorName"; "Number" = "$Commit" }
			}
			else
			{
				$Response.items | % {
					$ChangeLog += New-Object -Type PSObject -Property @{ "Title" = $_.title; "Type" = "PullRequest"; "User" = $_.user.login; "Number" = $_.number }
				}
			}


			if ( $Commits.IndexOf( $_ ) % 5 -Eq 0 )
			{
				$elapsedTime = New-TimeSpan
				$waitSeconds = 10
				while ( $(Get-RemainingSearches) -Lt 5 ) {
					Write-Progress -ParentId 1 -Id 2 -Activity "Waiting for API rate limiting" -CurrentOperation "Polling" -Status "$($elapsedTime.Seconds) seconds elapsed"
					Start-Sleep -Seconds $waitSeconds
					$elapsedTime = $elapsedTime.Add( "00:00:$waitSeconds" )
					Write-Progress -Id 2 -Completed -Activity "Waiting for API rate limiting"
				}
			}
		}

	$ChangeLog = $ChangeLog | Sort-Object -Property "Number" -Unique
	$ChangeLog
}
