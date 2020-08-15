#Requires -Modules Aws.Tools.Common, AWS.Tools.SecurityToken, Microsoft.PowerShell.SecretManagement

function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateSet("Corp", "Pep")]
		[string] $Environment,

		[Parameter(Position = 1)]
		[ValidateSet("Sandbox", "Galileo", "Admin")]
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

		$awsCredential = Get-Secret "aws.amazon.com/iam/$($Environment.ToLower())"
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
	}

	function Set-PromptColor {
		param($ProfileName, $SessionExtension)

		$Global:StoredAWSCredentialPromptColor = switch ($ProfileName) {
			"Corp" { "Yellow" }
			"Corp$SessionExtension" { "Green" }
			"CorpSandbox$SessionExtension" { "Blue" }
			"CorpGalileo$SessionExtension" { "Magenta" }
			"CorpAdmin$SessionExtension" { "DarkRed" }
			"Pep" { "White" }
			"Pep$SessionExtension" { "DarkRed" }
			"PepAdmin$SessionExtension" { "Red" }
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

	function Start-NewSession {
		param(
			[Parameter(Mandatory)]
			[ValidateSet("Corp", "Pep")]
			[string] $Environment,

			[Parameter(Mandatory)]
			[string] $ProfileName,

			[Parameter(Mandatory)]
			[string] $RoleName,

			[Parameter(Mandatory)]
			[string] $SessionExtension
		)

		Clear-AWSDefaultSession $Environment

		$serialNumber = Get-MfaSerialNumber -Environment $Environment
		$tokenCode = Read-Host "Token Code ($Environment)"
		$stsSessionToken = Get-STSSessionToken -SerialNumber $serialNumber -TokenCode $tokenCode
		Set-EnvironmentFromToken `
			-Token $stsSessionToken `
			-SessionName "${Environment}$SessionExtension" `
			-SessionExtension $SessionExtension

		if (-Not $RoleName) { return }

		$roleArn = switch ($RoleName) {
			{$RoleName -eq "Sandbox"} { "arn:aws:iam::308326368506:role/ParentAccountAdministrator"; break }
			{$RoleName -eq "Galileo"} { "arn:aws:iam::978150820456:role/OrganizationAccountAccessRole"; break }
			{$RoleName -eq "Admin" -and $Environment -eq "Corp"} { "arn:aws:iam::174627156110:role/CareEvolutionAdministratorRole"; break }
			{$RoleName -eq "Admin" -and $Environment -eq "Pep"} { "arn:aws:iam::386335162752:role/OrganizationAccountAccessRole"; break }
		}
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
