#Requires -Modules Aws.Tools.Common, AWS.Tools.SecurityToken, Microsoft.PowerShell.SecretManagement, Aws.Tools.SSO

function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string] $ProfileName,

		[Parameter()]
		[switch] $IncludeWsl
	)

	function Set-Profile {
		param($ProfileName)
		$Env:AWS_PROFILE = $ProfileName
		Set-AWSCredential -ProfileName $ProfileName -Scope Global
	}

	Import-Module AWS.Tools.SSO
	Import-Module AWS.Tools.SSOOIDC

	try {
		if (-Not (Get-STSCallerIdentity -ProfileName $ProfileName -ErrorAction SilentlyContinue)) {
			throw "Not logged in"
		}
	}
	catch {
		Write-Verbose "Logging into SSO"
		aws sso login
		if ($IncludeWsl) {
			bash -c "aws sso login"
		}
	}
	Set-Profile $ProfileName
}

Set-Alias -Name sads -Value Set-AwsDefaultSession
