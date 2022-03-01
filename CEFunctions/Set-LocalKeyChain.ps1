function Set-LocalKeyChain {
	[CmdletBinding()]
	param()

	try {
		$Env:OP_SESSION_careevolution = Get-Secret "1Password" |
			ConvertFrom-SecureString -AsPlainText |
			op signin careevolution --raw
	} catch {
		throw "Unable to read from op"
	}

	$onlyPasswords = @{
		Corp = "Corp AD"
		Pep = "Pep AD"
		Hosted = "Hosted AD"
	}

	foreach ($onlyPassword in $onlyPasswords.GetEnumerator()) {
		$entry = op get item $onlyPassword.Value --vault "Private" | ConvertFrom-Json
		if (-not $entry) {
			throw "Cannot retrieve $($onlyPassword.Value)"
		}
		$fields = $entry.details.fields
		$password = $fields | Where-Object { $_.designation -eq "password" } | Select-Object -ExpandProperty Value

		Write-Verbose "Setting secret '$($onlyPassword.Key)' from op '$($onlyPassword.Value)'"
		Set-Secret -Name $onlyPassword.Key -SecureStringSecret ($password | ConvertTo-SecureString -AsPlainText)
	}

	$logins = @{
		BuildServer = "buildserver@corp"
	}

	foreach ($login in $logins.GetEnumerator()) {
		$entry = op get item $login.Value | ConvertFrom-Json
		if (-not $entry) {
			throw "Cannot retrieve $($login.Value)"
		}
		$fields = $entry.details.fields
		$username = $fields | Where-Object { $_.designation -eq "username" } | Select-Object -ExpandProperty Value
		$password = $fields | Where-Object { $_.designation -eq "password" } | Select-Object -ExpandProperty Value

		Write-Verbose "Setting secret '$($login.Key)' from op '$($login.Value)'"
		$secretCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($password | ConvertTo-SecureString -AsPlainText)
		Set-Secret -Name $apiCredential.Key -Secret $secretCredential
	}


	$apiCredentials = @{
		"aws.amazon.com/iam/corp" = "AWS Corp Access Key"
		"aws.amazon.com/iam/pep" = "AWS Pep Access Key"
	}

	foreach ($apiCredential in $apiCredentials.GetEnumerator()) {
		$entry = op get item $apiCredential.Value --vault "Private" | ConvertFrom-Json
		if (-not $entry) {
			throw "Cannot retrieve $($apiCredential.Value)"
		}
		$fields = $entry.details.sections.fields
		$username = $fields | Where-Object { $_.n -eq "username" } | Select-Object -ExpandProperty v
		$credential = $fields | Where-Object { $_.n -eq "credential" } | Select-Object -ExpandProperty v

		Write-Verbose "Setting secret '$($apiCredential.Key)' from op '$($apiCredential.Value)'"
		$secretCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($credential | ConvertTo-SecureString -AsPlainText)
		Set-Secret -Name $apiCredential.Key -Secret $secretCredential
	}
}
