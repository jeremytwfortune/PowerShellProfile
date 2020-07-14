#Requires -Modules Aws.Tools.Common
#Requires -Modules AWS.Tools.SecurityToken

function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateSet("Corp", "Pep")]
		[string] $Environment,

		[Parameter(Position = 1)]
		[ValidateSet("Sandbox", "Admin")]
		[string] $RoleName
	)

	function Clear-AwsDefaultSession {
		param(
			[Parameter(Mandatory)]
			[ValidateSet("Corp", "Pep")]
			[string] $Environment
		)

		Write-Verbose "Clearing AWS session, setting to '$Environment'"
		"Machine", "User", "Process" | %{
			[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", "", [System.EnvironmentVariableTarget]::$_)
			[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "", [System.EnvironmentVariableTarget]::$_)
			[Environment]::SetEnvironmentVariable("AWS_SESSION_TOKEN", "", [System.EnvironmentVariableTarget]::$_)
		}

		if ($awsCredential = Get-Secret "aws.amazon.com/iam/$($Environment.ToLower())") {
			$Env:AWS_ACCESS_KEY_ID = $awsCredential.UserName
			$Env:AWS_SECRET_ACCESS_KEY = $awsCredential.GetNetworkCredential().Password
		}
		if (-Not ($storedCredential = Get-AWSCredential -ProfileName $Environment) -or
			$storedCredential.GetCredentials().AccessKey -ne $Env:AWS_ACCESS_KEY_ID) {
				Write-Verbose "Credentials file contains a different access key, updating file"
				Set-AWSCredential `
					-AccessKey $Env:AWS_ACCESS_KEY_ID `
					-SecretKey $Env:AWS_SECRET_ACCESS_KEY `
					-StoreAs $Environment `
					-ProfileLocation $HOME\.aws\credentials
		}
		Set-AWSCredential -ProfileName $Environment -Scope Global

		switch ($Environment) {
			"Corp" { $Env:AWS_MFA_SERIAL = "arn:aws:iam::174627156110:mfa/jeremy" }
			"Pep" { $Env:AWS_MFA_SERIAL = "arn:aws:iam::621233246578:mfa/jeremy.fortune" }
		}
	}

	function Set-PromptColor {
		param($ProfileName, $SessionExtension)

		$Global:StoredAWSCredentialPromptColor = switch ($ProfileName) {
			"Corp" { "Magenta" }
			"Corp$SessionExtension" { "DarkMagenta" }
			"CorpSandbox$SessionExtension" { "Blue" }
			"CorpAdmin$SessionExtension" { "Green" }
			"Pep" { "Red" }
			"Pep$SessionExtension" { "DarkRed" }
			"PepAdmin$SessionExtension" { "White" }
		}
	}

	function Convert-SessionToConvention {
		param($SessionName, $SessionExtension)
		switch ($SessionName) {
			"Corp$SessionExtension" { "mfa" }
			"CorpSandbox$SessionExtension" { "sandbox" }
			"CorpAdmin$SessionExtension" { "admin" }
			"Pep$SessionExtension" { "pep" }
			"PepAdmin$SessionExtension" { "restricted" }
		}
	}

	function Set-EnvironmentFromToken {
		param($Token, $SessionName, $SessionExtension)

		Write-Verbose "Setting profile '$SessionName'"
		Set-AWSCredential `
			-AccessKey $Token.AccessKeyId `
			-SecretKey $Token.SecretAccessKey `
			-SessionToken $Token.SessionToken `
			-StoreAs $SessionName `
			-ProfileLocation $HOME\.aws\credentials
		if ($convertedSession = Convert-SessionToConvention -SessionName $SessionName -SessionExtension $SessionExtension) {
			Write-Verbose "Setting conventional profile '$convertedSession'"
			Set-AWSCredential `
				-AccessKey $Token.AccessKeyId `
				-SecretKey $Token.SecretAccessKey `
				-SessionToken $Token.SessionToken `
				-StoreAs $convertedSession `
				-ProfileLocation $HOME\.aws\credentials
		}
		Set-AWSCredential -ProfileName $SessionName -Scope Global
		$Env:AWS_ACCESS_KEY_ID = $Token.AccessKeyId
		$Env:AWS_SECRET_ACCESS_KEY = $Token.SecretAccessKey
		$Env:AWS_SESSION_TOKEN = $Token.SessionToken
		Set-PromptColor -ProfileName $SessionName -SessionExtension $SessionExtension
	}

	function Start-NewSession {
		param(
			$Environment,
			$ProfileName,
			$RoleName,
			$SessionExtension
		)

		Clear-AWSDefaultSession $Environment

		$TokenCode = Read-Host "Token Code ($Environment)"

		$stsSessionToken = Get-STSSessionToken -SerialNumber $Env:AWS_MFA_SERIAL -TokenCode $TokenCode
		Set-EnvironmentFromToken `
			-Token $stsSessionToken `
			-SessionName "${Environment}$SessionExtension" `
			-SessionExtension $SessionExtension

		if (-Not $RoleName) { return }

		$roleArn = switch ($RoleName) {
			{"Sandbox"} { "arn:aws:iam::308326368506:role/ParentAccountAdministrator"; break }
			{"Admin" -and $Environment -eq "Corp"} { "arn:aws:iam::174627156110:role/CareEvolutionAdministratorRole"; break }
			{"Admin" -and $Environment -eq "Pep"} { "arn:aws:iam::386335162752:role/OrganizationAccountAccessRole"; break }
		}
		$stsRole = Use-STSRole `
			-RoleArn $roleArn `
			-ProfileName "${Environment}$SessionExtension" `
			-RoleSessionName $profileName
		Set-EnvironmentFromToken `
			-Token $stsRole.Credentials `
			-SessionName $profileName `
			-SessionExtension $SessionExtension
	}

	function Test-ExistingSession {
		param($ProfileName)

		try {
			if ($sts = Get-STSCallerIdentity -ProfileName $ProfileName -ErrorAction SilentlyContinue) {
				return $True
			}
		} catch {}
		$False
	}

	$ErrorActionPreference = "Stop"
	$SESSION_EXTENSION = "Session"
	$profileName = "$Environment$RoleName$SESSION_EXTENSION"

	if (Test-ExistingSession -ProfileName $ProfileName) {
		Write-Verbose "Found existing valid session for '$ProfileName'"
		Set-PromptColor -ProfileName $ProfileName -SessionExtension $SESSION_EXTENSION
		Set-AWSCredential -ProfileName $ProfileName -Scope Global
		return
	}

	Start-NewSession `
		-Environment $Environment `
		-ProfileName $ProfileName `
		-RoleName $RoleName `
		-SessionExtension $SESSION_EXTENSION
}

Set-Alias -Name sads -Value Set-AwsDefaultSession
