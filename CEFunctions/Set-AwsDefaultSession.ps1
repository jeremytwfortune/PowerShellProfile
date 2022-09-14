#Requires -Modules Aws.Tools.Common, AWS.Tools.SecurityToken, Microsoft.PowerShell.SecretManagement

function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[string] $ProfileName
	)
	end {
		function Initialize-AwsDefaultSession {
			param(
				[Parameter(Mandatory)]
				[ValidateSet("Corp", "Pep")]
				[string] $Environment
			)

			Write-Verbose "Clearing AWS session, setting to '$Environment'"
			Clear-AWSCredential -Scope Global

			Write-Verbose "Obtaining credentials from keyring"
			$awsCredential = Get-Secret "aws.amazon.com/iam/$($Environment.ToLower())"
			Write-Verbose "Loading profile from credentials file"
			$storedCredential = Get-AWSCredential -ProfileName $Environment
			if ($awsCredential -And (-Not ($storedCredential) -Or $storedCredential.GetCredentials().AccessKey -Ne $awsCredential.UserName)) {
				Write-Verbose "Credentials file contains a different access key, updating file"
				Set-AWSCredential `
					-AccessKey $awsCredential.UserName `
					-SecretKey $awsCredential.GetNetworkCredential().Password `
					-StoreAs $Environment `
					-ProfileLocation $HOME\.aws\credentials
			}
			Set-AWSCredential -ProfileName $Environment -Scope Global
			$Env:AWS_PROFILE = $Environment
		}

		function Convert-SessionToConvention {
			param($SessionName, $SessionExtension)
			switch ($SessionName) {
				"Pep$SessionExtension" { "pep" }
			}
		}

		function Set-EnvironmentFromToken {
			[CmdletBinding()]
			param(
				[Parameter(Mandatory)]
				[Amazon.SecurityToken.Model.Credentials] $Token,

				[Parameter(Mandatory)]
				[string] $SessionName,

				[Parameter(Mandatory)]
				[string] $SessionExtension
			)

			Write-Verbose "Setting profile '$SessionName'"
			Set-AWSCredential `
				-AccessKey $Token.AccessKeyId `
				-SecretKey $Token.SecretAccessKey `
				-SessionToken $Token.SessionToken `
				-StoreAs $SessionName `
				-ProfileLocation $HOME\.aws\credentials
			if ($convertedSessions = Convert-SessionToConvention -SessionName $SessionName -SessionExtension $SessionExtension) {
				Write-Verbose "Setting conventional profiles '$convertedSessions'"
				$convertedSessions -split "," | % {
					Set-AWSCredential `
						-AccessKey $Token.AccessKeyId `
						-SecretKey $Token.SecretAccessKey `
						-SessionToken $Token.SessionToken `
						-StoreAs $_ `
						-ProfileLocation $HOME\.aws\credentials
				}
			}
			Set-AWSCredential -ProfileName $SessionName -Scope Global
			$Env:AWS_PROFILE = $SessionName
		}

		function Get-MfaSerialNumber {
			param(
				[Parameter(Mandatory)]
				[ValidateSet("Corp", "Pep")]
				[string] $Environment
			)

			$userName = Get-STSCallerIdentity -ProfileName $Environment |
				Select-Object -ExpandProperty arn |
				ForEach-Object { $_ -split '/' } |
				Select-Object -Last 1
			$mfaDevice = Get-IAMMFADevice -UserName $userName -ProfileName $Environment
			$mfaDevice.SerialNumber
		}

		function Test-ExistingSession {
			param(
				[Parameter(Mandatory)]
				$ProfileName
			)

			try {
				$sts = Get-STSCallerIdentity -ProfileName $ProfileName -ErrorAction SilentlyContinue
				if ($sts) {
					return $True
				}
			}
			catch {}
			$False
		}

		function Read-TokenCode {
			param(
				[Parameter(Mandatory)]
				[ValidateSet("Corp", "Pep")]
				[string] $Environment
			)

			$totpMap = @{
				"Corp" = "Main IAM"
				"Pep" = "PEP IAM"
			}

			try {
				Connect-OnePassword | Out-Null
				$totp = op item get $totpMap[$Environment] --otp
			}
			catch {}
			if ($totp) {
				return $totp
			}
			Read-Host "Token Code ($Environment)"
		}

		function Start-NewSession {
			[CmdletBinding()]
			param(
				[Parameter(Mandatory)]
				[ValidateSet("Corp", "Pep")]
				[string] $Environment,

				[Parameter(Mandatory)]
				[string] $ProfileName,

				[Parameter(Mandatory)]
				[string] $SessionExtension,

				[string] $RoleName
			)

			Initialize-AWSDefaultSession $Environment

			if (Test-ExistingSession -ProfileName "${Environment}$SessionExtension") {
				return
			}

			$serialNumber = Get-MfaSerialNumber -Environment $Environment
			$tokenCode = Read-TokenCode -Environment $Environment
			$stsSessionToken = Get-STSSessionToken -SerialNumber $serialNumber -TokenCode $tokenCode -DurationInSeconds 43200
			Set-EnvironmentFromToken `
				-Token $stsSessionToken `
				-SessionName "${Environment}$SessionExtension" `
				-SessionExtension $SessionExtension
		}

		$ErrorActionPreference = "Stop"
		if ($ProfileName -ieq "pep") {
			$SESSION_EXTENSION = "Session"
			$sessionedProfileName = "$ProfileName$SESSION_EXTENSION"

			if (Test-ExistingSession -ProfileName $sessionedProfileName) {
				Write-Verbose "Found existing valid session for '$sessionedProfileName'"
				Set-AWSCredential -ProfileName $sessionedProfileName -Scope Global
				$Env:AWS_PROFILE = $sessionedProfileName
				return
			}

			Start-NewSession `
				-Environment $Profile `
				-ProfileName $sessionedProfileName `
				-RoleName $roleName `
				-SessionExtension $SESSION_EXTENSION
		}
		else {
			try {
				if (-Not (Get-STSCallerIdentity -ProfileName $ProfileName -ErrorAction SilentlyContinue)) {
					throw "Not logged in"
				}
			}
			catch {
				Write-Verbose "Logging into SSO"
				aws sso login --profile $ProfileName
			}
			Set-AWSCredential -ProfileName $ProfileName -Scope Global
			$Env:AWS_PROFILE = $ProfileName
		}
	}
}

Set-Alias -Name sads -Value Set-AwsDefaultSession
