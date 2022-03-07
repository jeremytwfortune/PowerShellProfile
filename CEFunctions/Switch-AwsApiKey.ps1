#Requires -Modules Microsoft.PowerShell.SecretManagement

function Switch-AwsApiKey {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[ValidateSet("Corp", "Pep", IgnoreCase=$False)]
		$Environment
	)

	function Test-AwsContainsKey {
		param($Key)

		$awsListedKeys = Get-IAMAccessKey
		$awsListedKeys.AccessKeyId -contains $Key
	}

	$SECRET_NAME = "aws.amazon.com/iam/$($Environment.ToLower())"

	$currentSecret = Get-Secret -Name $SECRET_NAME
	if (-not (Test-AwsContainsKey $currentSecret.UserName)) {
		throw "Listed access keys do not contain the current key $($currentSecret.UserName)"
	}

	$newKey = New-IAMAccessKey
	Write-Verbose "Replacing $($currentSecret.UserName) with $($newKey.AccessKeyId)"

	if (-not (Connect-OnePassword)) {
		throw "Unable to read from op; Key $($newKey.AccessKeyId) has not been synced and should be removed."
	}

	op edit item "AWS $Environment Access Key" username=$($newKey.AccessKeyId) credential=$($newKey.SecretAccessKey) --vault "Private"

	Set-LocalKeyChain

	if (-not (Test-AwsContainsKey $newKey.AccessKeyId)) {
		throw "Listed access keys do not contain the new key $($newKey.AccessKeyId)"
	}

	Remove-IAMAccessKey -AccessKeyId $currentSecret.UserName -Force

	New-Object -Type PSObject -Property @{
		OldKey = $currentSecret.UserName
		NewKey = $newKey.AccessKeyId
	}
}
