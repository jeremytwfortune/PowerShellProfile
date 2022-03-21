#Requires -Modules Aws.Tools.Common, AWS.Tools.SecurityToken, Microsoft.PowerShell.SecretManagement

function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateSet("Corp", "Pep", IgnoreCase=$False)]
		[string] $Environment
	)
	dynamicparam {
		$roleParameterName = "RoleName"
		$locationData = "$Home\AwsAssumableRoles.txt"
		if ( -Not ( Test-Path $locationData -ErrorAction SilentlyContinue ) ) {
			throw "File '$locationData' cannot be found"
		}
		$roleNames = Get-Content $locationData | ConvertFrom-StringData

		$attributeList = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		$attributeValidateSet = New-Object System.Management.Automation.ValidateSetAttribute($roleNames.Keys)
		$attributeList.Add($attributeValidateSet)

		$attributeParameter = New-Object System.Management.Automation.ParameterAttribute
		$attributeParameter.Mandatory = $False
		$attributeParameter.Position = 2
		$attributeList.Add($attributeParameter)

		$parameter = New-Object System.Management.Automation.RuntimeDefinedParameter(
			$roleParameterName,
			[string],
			$attributeList
		)

		$parameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		$parameterDictionary.Add($roleParameterName, $parameter)
		$parameterDictionary
	}
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

		function Set-PromptColor {
			param($ProfileName, $SessionExtension)

			$Global:StoredAWSCredentialPromptColor = switch ($ProfileName) {
				"Corp" { "White" }
				"Pep" { "White" }
				"Corp$SessionExtension" { "Green" }
				"CorpSandbox$SessionExtension" { "Blue" }
				"CorpGalileo$SessionExtension" { "Magenta" }
				"Pep$SessionExtension" { "DarkRed" }
			}
		}

		function Convert-SessionToConvention {
			param($SessionName, $SessionExtension)
			switch ($SessionName) {
				"Corp$SessionExtension" { "mfa,admin" }
				"CorpSandbox$SessionExtension" { "sandbox" }
				"CorpGalileo$SessionExtension" { "galileo" }
				"CorpInfrastructure$SessionExtension" { "infrastructure" }
				"CorpPublicInfrastructure$SessionExtension" { "public-infrastructure" }
				"CorpTenantGroup$SessionExtension" { "tg" }
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
				$convertedSessions -split "," | %{
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
			Set-PromptColor -ProfileName $SessionName -SessionExtension $SessionExtension
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
			} catch {}
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
				$totp = op get totp $totpMap[$Environment]
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

			if (-Not (Test-ExistingSession -ProfileName "${Environment}$SessionExtension")) {
				$serialNumber = Get-MfaSerialNumber -Environment $Environment
				$tokenCode = Read-TokenCode -Environment $Environment
				$stsSessionToken = Get-STSSessionToken -SerialNumber $serialNumber -TokenCode $tokenCode -DurationInSeconds 43200
				Set-EnvironmentFromToken `
					-Token $stsSessionToken `
					-SessionName "${Environment}$SessionExtension" `
					-SessionExtension $SessionExtension
			}

			if (-Not $RoleName) { return }

			$roleArn = $roleNames.$RoleName
			Write-Verbose "Assuming role arn '$roleArn' under role name '$RoleName'"
			$stsRole = Use-STSRole `
				-RoleArn $roleArn `
				-ProfileName "${Environment}$SessionExtension" `
				-RoleSessionName $profileName
			Set-EnvironmentFromToken `
				-Token $stsRole.Credentials `
				-SessionName $profileName `
				-SessionExtension $SessionExtension
		}


		$ErrorActionPreference = "Stop"
		$SESSION_EXTENSION = "Session"
		$roleName = $PSBoundParameters[$roleParameterName]
		$profileName = "$Environment$roleName$SESSION_EXTENSION"

		if (Test-ExistingSession -ProfileName $ProfileName) {
			Write-Verbose "Found existing valid session for '$ProfileName'"
			Set-PromptColor -ProfileName $ProfileName -SessionExtension $SESSION_EXTENSION
			Set-AWSCredential -ProfileName $ProfileName -Scope Global
			$Env:AWS_PROFILE = $ProfileName
			return
		}

		Start-NewSession `
			-Environment $Environment `
			-ProfileName $ProfileName `
			-RoleName $roleName `
			-SessionExtension $SESSION_EXTENSION
	}
}

Set-Alias -Name sads -Value Set-AwsDefaultSession
