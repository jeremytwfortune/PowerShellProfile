function New-OrchestrateHeaders {
	[CmdletBinding()]
	param()

	@{
		"X-Api-Key" = Get-Secret "Rosetta" -AsPlainText
		"Content-Type" = "application/json"
		Accept = "application/json"
	}
}
