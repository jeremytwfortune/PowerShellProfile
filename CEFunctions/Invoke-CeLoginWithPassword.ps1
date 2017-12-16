function Invoke-CELoginWithPassword {
	param(
	    [Parameter(
				Position=0,
				ValueFromPipelineByPropertyName)]
			[ValidateNotNullOrEmpty()]
			[PSCredential] $Credential,

			[Parameter(Position=1)]
			[ValidateNotNullOrEmpty()]
			[string] $ServerPath = $Env:CE_SERVERPATH,

			[Parameter(Position=2)]
			[ValidateNotNullOrEmpty()]
			[string] $ResourceOwnerClientID = "$Env:CE_CLIENTID",

			[Parameter(Position=3)]
			[ValidateNotNullOrEmpty()]
			[string] $ClientSecret = $Env:CE_CLIENTSECRET,

	    [Parameter(Position=4)]
			[string] $Scope = "openid offline_access api legacy-oauth2-compatible-api"
	)

	$ServerPath = $ServerPath.TrimEnd("/")
	$Url = "${ServerPath}/identityserver/connect/token"

	$Body = @{
	    grant_type = "password"
	    username = $Credential.UserName
	    password = $Credential.GetNetworkCredential().Password
	    client_id = $ResourceOwnerClientID
	    client_secret = $ClientSecret
	    scope = $Scope
	}

	$Response = Invoke-RestMethod -Method Post -Uri $Url -Body $body

	New-Object PSObject -prop @{
	    ClientID = $ResourceOwnerClientID
	    AccessToken = $Response.access_token
	    RefreshToken = $Response.refresh_token
	}
}
