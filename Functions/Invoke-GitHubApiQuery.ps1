function Invoke-GitHubApiQuery
{
	Param(
		[Parameter( Mandatory = $True )]
		[string]$Query,

		[Parameter( Mandatory = $True )]
		[string]$OAuthToken,

		[Parameter()]
		[hashtable]$Headers
	)

	$GitHubApiBaseUrl = "https://api.github.com"
	if( !$Headers )
	{
		$Headers = @{ "Authorization" = "token $OAuthToken" }
	}
	else
	{
		$Headers["Authorization"] = "token $OAuthToken"
	}

	Invoke-WebRequest -Headers $Headers -Uri "$GitHubApiBaseUrl/$Query"
}
