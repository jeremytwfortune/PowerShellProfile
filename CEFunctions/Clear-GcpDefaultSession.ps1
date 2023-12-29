function Clear-GcpDefaultSession {
	[CmdletBinding()]
	param()

	Write-Verbose "Clearing GCP session"
	$Env:GCP_PROJECT = $null
	# gcloud auth application-default revoke
	gcloud auth revoke

}

Set-Alias -Name cgds -Value Clear-GcpDefaultSession
