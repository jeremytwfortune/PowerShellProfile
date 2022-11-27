function Set-LocalKeyChain {
	[CmdletBinding()]
	param()

	if (-not (Connect-OnePassword)) {
		throw "Unable to read from op"
	}

	$onlyPasswords = @{
		Corp = @{
			Password = "op://Private/Corp AD/password"
		}
		Pep = @{
			Password = "op://Private/Pep AD/password"
		}
		Hosted = @{
			Password = "op://Private/Hosted AD/password"
		}
	}

	foreach ($onlyPassword in $onlyPasswords.GetEnumerator()) {
		Write-Verbose "Setting secret '$($onlyPassword.Name)' from op"
		$password = $onlyPassword.Value.Password | op inject
		Set-Secret -Name $onlyPassword.Name -SecureStringSecret ($password | ConvertTo-SecureString -AsPlainText)
	}

	$logins = @{
		BuildServer = @{
			Username = "op://CareEvolution.Infrastructure/uw4cpfxhjtzbpr7uefelhap25y/username"
			Password = "op://CareEvolution.Infrastructure/uw4cpfxhjtzbpr7uefelhap25y/password"
		}
	}

	foreach ($login in $logins.GetEnumerator()) {
		$username = $login.Value.Username | op inject
		$password = $login.Value.Password | op inject
		Write-Verbose "Setting secret '$($login.Name)' from op '$username'"
		$secretCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($password | ConvertTo-SecureString -AsPlainText)
		Set-Secret -Name $login.Name -Secret $secretCredential
	}


	$apiCredentials = @{
		"aws.amazon.com/iam/corp" = @{
			Username = "op://Private/AWS Corp Access Key/username"
			Credential = "op://Private/AWS Corp Access Key/credential"
		}
		"aws.amazon.com/iam/pep" = @{
			Username = "op://Private/AWS Pep Access Key/username"
			Credential = "op://Private/AWS Pep Access Key/credential"
		}
	}

	foreach ($apiCredential in $apiCredentials.GetEnumerator()) {
		$username = $apiCredential.Value.Username | op inject
		$credential = $apiCredential.Value.Credential | op inject
		Write-Verbose "Setting secret '$($apiCredential.Name)' from op '$username'"
		$secretCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($credential | ConvertTo-SecureString -AsPlainText)
		Set-Secret -Name $apiCredential.Name -Secret $secretCredential
	}
}
