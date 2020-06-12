#Requires -Modules Aws.Tools.Common
#Requires -Modules AWS.Tools.SecurityToken

function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)]
		[ValidateSet("Corp", "Pep")]
		[string] $Environment,

		[Parameter(Position = 1)]
		[ValidateSet("Sandbox")]
		[string] $RoleName,

		[Parameter()]
		[string] $TokenCode = (Read-Host "Token Code")
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
			"Pep" { "Red" }
			"CorpSandbox$SessionExtension" { "Blue" }
			"Corp$SessionExtension" { "DarkMagenta" }
			"Pep$SessionExtension" { "DarkRed" }
		}
	}

	function Convert-SessionToConvention {
		param($SessionName, $SessionExtension)
		switch ($SessionName) {
			"Corp$SessionExtension" { "mfa" }
			"CorpSandbox$SessionExtension" { "sandbox" }
			"Pep$SessionExtension" { "pep" }
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

	Clear-AWSDefaultSession $Environment
	$SESSION_EXTENSION = "Session"
	$profileName = "${Environment}$SESSION_EXTENSION"

	$stsSessionToken = Get-STSSessionToken -SerialNumber $Env:AWS_MFA_SERIAL -TokenCode $TokenCode
	Set-EnvironmentFromToken `
		-Token $stsSessionToken `
		-SessionName "${Environment}$SESSION_EXTENSION" `
		-SessionExtension $SESSION_EXTENSION

	if (-Not $RoleName) { return }

	switch ($RoleName) {
		"Sandbox" { $roleArn = "arn:aws:iam::308326368506:role/ParentAccountAdministrator" }
	}
	$stsRole = Use-STSRole `
		-RoleArn $roleArn `
		-ProfileName $profileName `
		-RoleSessionName $profileName
	$profileName = "$Environment$RoleName$SESSION_EXTENSION"
	Set-EnvironmentFromToken `
		-Token $stsRole.Credentials `
		-SessionName $profileName `
		-SessionExtension $SESSION_EXTENSION
}

Set-Alias -Name sads -Value Set-AwsDefaultSession
