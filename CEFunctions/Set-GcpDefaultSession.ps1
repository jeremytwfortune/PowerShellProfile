function Set-GcpDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter()]
		[string] $Project
	)

	$accounts = gcloud auth list --format=json | ConvertFrom-Json
	if ($accounts.Count -eq 0) {
		gcloud auth login
		# gcloud auth login --update-adc
	}

	if (-not $Project) {
		return
	}

	# gcloud auth application-default set-quota-project $Project
	gcloud config set project $Project
}

Set-Alias -Name sgds -Value Set-GcpDefaultSession
