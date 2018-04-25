function Get-GitHubChangeLog {
	param(
		[Parameter( Mandatory )]
		[string]$CommitRange,

		[Parameter( Mandatory )]
		[string]$OAuthToken,

		[Parameter( Mandatory )]
		[string]$RepositoryOwner,

		[Parameter( Mandatory )]
		[string]$RepositoryName
	)

	function Get-RemainingSearches {
		$Response = Invoke-GitHubApiQuery -OAuthToken $OAuthToken -Query "rate_limit" |
			Select-Object -ExpandProperty "Content" |
			ConvertFrom-Json
		$Response.Resources.search.remaining
	}

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$ChangeLog = @()
	$Commits = git log $CommitRange --pretty="%H"
	$Commits | %{
		Write-Progress `
			-Id 1 `
			-Activity "Querying API" `
			-CurrentOperation "Commit: $_" `
			-PercentComplete ( 100 * $Commits.IndexOf( $_ ) / $Commits.Count )
		try {
			$Response = (
				Invoke-GitHubApiQuery `
					-OAuthToken $OAuthToken `
					-Headers @{ "Accept" = "application/vnd.github.cloak-preview" } `
					-Query "search/issues?q=repo:$RepositoryOwner/$RepositoryName+hash:$_" |
				Select-Object -ExpandProperty "Content" |
				ConvertFrom-Json
			)
		}
		catch [System.Net.WebException] {
			Write-Host $Error[0].ErrorDetails.Message
			break
		}

		if ( $Response.total_count -Eq 0 ) {
			$CommitTitle = git log -1 --pretty="%s" $_
			$CommitAuthorName = git log -1 --pretty="%an" $_
			$Commit = git log -1 --pretty="%h" $_
			$Body = git log -1 --pretty="%b" $_
			if ( $Body -is [Array] ) {
				$Body = $Body -join "`n"
			}
			$ChangeLog += New-Object -Type PSObject -Property @{
				"Title" = $CommitTitle
				"Type" = "Commit"
				"User" = $CommitAuthorName
				"Number" = $Commit
				"Tags" = @("Commit")
				"Body" = $Body
			}
		} else {
			$Response.items | % {
				$Labels = $_.labels
				if ( $Labels ) {
					$Tags = $Labels.name
				}
				$ChangeLog += New-Object -Type PSObject -Property @{
					"Title" = $_.title
					"Type" = "PullRequest"
					"User" = $_.user.login
					"Number" = $_.number
					"Tags" = $Tags
					"Body" = $_.body
				}
			}
		}

		if ( $Commits.IndexOf( $_ ) % 5 -Eq 0 )
		{
			$elapsedTime = New-TimeSpan
			$waitSeconds = 10
			while ( ( Get-RemainingSearches ) -Lt 5 ) {
				Write-Progress `
					-ParentId 1 `
					-Id 2 `
					-Activity "Waiting for API rate limiting" `
					-CurrentOperation "Polling" `
					-Status "$($elapsedTime.Seconds) seconds elapsed"
				Start-Sleep -Seconds $waitSeconds
				$elapsedTime = $elapsedTime.Add( "00:00:$waitSeconds" )
				Write-Progress `
					-Id 2 `
					-Completed `
					-Activity "Waiting for API rate limiting"
			}
		}
	}

	$ChangeLog = $ChangeLog | Sort-Object -Property "Number" -Unique
	$ChangeLog
}
