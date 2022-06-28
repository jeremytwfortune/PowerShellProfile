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
		$entry = op item get $onlyPassword.Value --vault "Private" --format json | ConvertFrom-Json
		if (-not $entry) {
			throw "Cannot retrieve $($onlyPassword.Value)"
		}
		$fields = $entry.fields
		$password = $fields | Where-Object { $_.purpose -eq "password" } | Select-Object -ExpandProperty Value

		Write-Verbose "Setting secret '$($onlyPassword.Key)' from op '$($onlyPassword.Value)'"
		Set-Secret -Name $onlyPassword.Key -SecureStringSecret ($password | ConvertTo-SecureString -AsPlainText)
	}

	$logins = @{
		BuildServer = "buildserver@corp"
	}

	foreach ($login in $logins.GetEnumerator()) {
		$entry = op item get $login.Value --vault "CareEvolution.Infrastructure" --format json | ConvertFrom-Json
		if (-not $entry) {
			throw "Cannot retrieve $($login.Value)"
		}
		$fields = $entry.fields
		$username = $fields | Where-Object { $_.purpose -eq "username" } | Select-Object -ExpandProperty Value
		$password = $fields | Where-Object { $_.purpose -eq "password" } | Select-Object -ExpandProperty Value

		Write-Verbose "Setting secret '$($login.Key)' from op '$($login.Value)'"
		$secretCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($password | ConvertTo-SecureString -AsPlainText)
		Set-Secret -Name $login.Key -Secret $secretCredential
	}


	$apiCredentials = @{
		"aws.amazon.com/iam/corp" = "AWS Corp Access Key"
		"aws.amazon.com/iam/pep" = "AWS Pep Access Key"
	}

	foreach ($apiCredential in $apiCredentials.GetEnumerator()) {
		$entry = op item get $apiCredential.Value --vault "Private" --format json | ConvertFrom-Json
		if (-not $entry) {
			throw "Cannot retrieve $($apiCredential.Value)"
		}
		$fields = $entry.fields
		$username = $fields | Where-Object { $_.id -eq "username" } | Select-Object -ExpandProperty value
		$credential = $fields | Where-Object { $_.id -eq "credential" } | Select-Object -ExpandProperty value

		Write-Verbose "Setting secret '$($apiCredential.Key)' from op '$($apiCredential.Value)'"
		$secretCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($credential | ConvertTo-SecureString -AsPlainText)
		Set-Secret -Name $apiCredential.Key -Secret $secretCredential
	}
}
