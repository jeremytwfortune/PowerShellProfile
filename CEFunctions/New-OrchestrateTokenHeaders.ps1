function New-OrchestrateTokenHeaders {
	[CmdletBinding()]
	param(
		[Parameter()]
		[string] $Url = "https://api.rosetta.careevolution.com"
	)

	$tokenUrl = "$Url/token"
	$bearer = Invoke-RestMethod `
		-Method Post `
		-Uri $tokenUrl `
		-Headers (New-OrchestrateHeaders) `
		-Body "{}"

	@{
		Authorization = "Bearer $($bearer.access_token)"
		"Content-Type" = "application/json"
		Accept = "application/json"
	}
}

Set-Alias "noth" New-OrchestrateTokenHeaders
