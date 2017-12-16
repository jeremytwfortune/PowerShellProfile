function Invoke-GitAddPullRequests {
	param (
		[string] $Remote = "origin"
	)
	git config --local --add remote.$Remote.fetch +refs/pull/*/head:refs/remotes/$Remote/pull/*
	git fetch --all --prune
}
