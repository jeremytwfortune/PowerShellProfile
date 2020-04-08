#Requires -Modules AWS.Tools.SecurityToken

function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[ValidateSet("Corp", "Pep")]
		[string] $Environment,

		[Parameter()]
		[string] $TokenCode = (Read-Host "Token Code"),

		[Parameter()]
		[ValidateSet("Sandbox")]
		[string] $RoleName
	)

	function Clear-AwsDefaultSession {
		param(
			[Parameter(Mandatory)]
			[ValidateSet("Corp", "Pep")]
			[string] $Environment
		)

		"Machine", "User", "Process" | %{
			[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", "", [System.EnvironmentVariableTarget]::$_)
			[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "", [System.EnvironmentVariableTarget]::$_)
			[Environment]::SetEnvironmentVariable("AWS_SESSION_TOKEN", "", [System.EnvironmentVariableTarget]::$_)
		}

		if ($awsCredential = Get-Secret "aws.amazon.com/iam/$($Environment.ToLower())") {
			$Env:AWS_ACCESS_KEY_ID = $awsCredential.UserName
			$Env:AWS_SECRET_ACCESS_KEY = $awsCredential.GetNetworkCredential().Password
			Set-AWSCredential -ProfileName $Environment -Scope Global
		}

		switch ($Environment) {
			"Corp" { $Env:AWS_MFA_SERIAL = "arn:aws:iam::174627156110:mfa/jeremy" }
			"Pep" { $Env:AWS_MFA_SERIAL = "arn:aws:iam::621233246578:mfa/jeremy.fortune" }
		}
	}

	function Set-EnvironmentFromToken {
		param($Token, $SessionName)

		Set-AWSCredential `
			-AccessKey $Token.AccessKeyId `
			-SecretKey $Token.SecretAccessKey `
			-SessionToken $Token.SessionToken `
			-StoreAs $SessionName `
			-ProfileLocation $HOME\.aws\credentials
		Set-AWSCredential -ProfileName $SessionName -Scope Global
	}

	Clear-AWSDefaultSession $Environment
	$profileName = "${Environment}Session"

	$stsSessionToken = Get-STSSessionToken -SerialNumber $Env:AWS_MFA_SERIAL -TokenCode $TokenCode
	Set-EnvironmentFromToken -Token $stsSessionToken -SessionName "${Environment}Session"

	if (-Not $RoleName) { return }

	switch ($RoleName) {
		"Sandbox" { $roleArn = "arn:aws:iam::308326368506:role/ParentAccountAdministrator" }
	}
	$stsRole = Use-STSRole `
		-RoleArn $roleArn `
		-ProfileName $profileName `
		-RoleSessionName $profileName
	$profileName = "${RoleName}Session"
	Set-EnvironmentFromToken -Token $stsRole.Credentials -SessionName $profileName
}