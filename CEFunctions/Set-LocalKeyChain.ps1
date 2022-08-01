function Set-LocalKeyChain {
	[CmdletBinding()]
	param()

	if (-not (Connect-OnePassword)) {
		throw "Unable to read from op"
	}

	$onlyPasswords = @{
		Corp = "Corp AD"
		Pep = "Pep AD"
		Hosted = "Hosted AD"
	}

	foreach ($onlyPassword in $onlyPasswords.GetEnumerator()) {
		$password = "op://Private/$($onlyPassword.Value)/password" | op inject
		if (-not $password) {
			throw "Cannot retrieve $($onlyPassword.Value)"
		}

		Write-Verbose "Setting secret '$($onlyPassword.Key)' from op '$($onlyPassword.Value)'"
		Set-Secret -Name $onlyPassword.Key -SecureStringSecret ($password | ConvertTo-SecureString -AsPlainText)
	}


	$username = "op://CareEvolution.Infrastructure/uw4cpfxhjtzbpr7uefelhap25y/username" | op inject
	$password = "op://CareEvolution.Infrastructure/uw4cpfxhjtzbpr7uefelhap25y/password" | op inject

	if ((-not $username) -or (-not $password)) {
		throw "Cannot retrieve $($login.Value)"
	}
	Write-Verbose "Setting secret 'BuildServer' from op 'buildserver@corp'"
	$secretCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($password | ConvertTo-SecureString -AsPlainText)
	Set-Secret -Name "BuildServer" -Secret $secretCredential


	$apiCredentials = @{
		"aws.amazon.com/iam/corp" = "AWS Corp Access Key"
		"aws.amazon.com/iam/pep" = "AWS Pep Access Key"
	}

	foreach ($apiCredential in $apiCredentials.GetEnumerator()) {
		$username = "op://Private/$($apiCredential.Value)/username" | op inject
		$credential = "op://Private/$($apiCredential.Value)/credential" | op inject
		if ((-not $username) -or (-not $credential)) {
			throw "Cannot retrieve $($apiCredential.Value)"
		}

		Write-Verbose "Setting secret '$($apiCredential.Key)' from op '$($apiCredential.Value)'"
		$secretCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($credential | ConvertTo-SecureString -AsPlainText)
		Set-Secret -Name $apiCredential.Key -Secret $secretCredential
	}
}
