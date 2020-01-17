function Set-AwsDefaultSession {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[ValidateSet("Corp", "Pep")]
		[string] $Environment
	)

	$target = "aws.amazon.com/iam/$($Environment.ToLower())"
	if ( $awsCredential = Get-StoredCredential -Type Generic -WarningAction SilentlyContinue -Target $target ) {
		Set-AWSCredential -AccessKey $awsCredential.UserName -SecretKey $awsCredential.GetNetworkCredential().Password
		$Env:AWS_ACCESS_KEY_ID = $awsCredential.UserName
		$Env:AWS_SECRET_ACCESS_KEY = $awsCredential.GetNetworkCredential().Password
	}

	switch ($Environment) {
		"Corp" { $Env:AWS_MFA_SERIAL = "arn:aws:iam::174627156110:mfa/jeremy" }
		"Pep" { $Env:AWS_MFA_SERIAL = "arn:aws:iam::621233246578:mfa/jeremy.fortune" }
	}
}