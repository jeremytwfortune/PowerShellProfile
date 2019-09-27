function Clear-AwsDefaultSession {
	"Machine", "User", "Process" | %{
		[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", "", [System.EnvironmentVariableTarget]::$_)
		[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "", [System.EnvironmentVariableTarget]::$_)
		[Environment]::SetEnvironmentVariable("AWS_SESSION_TOKEN", "", [System.EnvironmentVariableTarget]::$_)
	}

	if ( $awsCredential = Get-StoredCredential -Type Generic -WarningAction SilentlyContinue -Target "aws.amazon.com/iam" ) {
		Set-AWSCredential -AccessKey $awsCredential.UserName -SecretKey $awsCredential.GetNetworkCredential().Password
		$Env:AWS_ACCESS_KEY_ID = $awsCredential.UserName
		$Env:AWS_SECRET_ACCESS_KEY = $awsCredential.GetNetworkCredential().Password
	}
}