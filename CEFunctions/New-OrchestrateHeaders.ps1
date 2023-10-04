function New-OrchestrateHeaders {
	[CmdletBinding()]
	param()

	@{
		"X-Api-Key" = Get-Secret "Orchestrate" -AsPlainText
		"Content-Type" = "application/json"
		Accept = "application/json"
	}
}
