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
		Set-AWSCredential -AccessKey $Env:AWS_ACCESS_KEY_ID -SecretKey $Env:AWS_SECRET_ACCESS_KEY
	}

	switch ($Environment) {
		"Corp" { $Env:AWS_MFA_SERIAL = "arn:aws:iam::174627156110:mfa/jeremy" }
		"Pep" { $Env:AWS_MFA_SERIAL = "arn:aws:iam::621233246578:mfa/jeremy.fortune" }
	}
}