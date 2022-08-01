function Set-LocalKeyChain {
	[CmdletBinding()]
	param()

	if (-not (Connect-OnePassword)) {
		throw "Unable to read from op"
	}

	function Convert-Injectable {
		param(
			[Parameter(ValueFromPipeline)]
			$InputObject
		)

		process {
			$InputObject |
				ConvertTo-Json -Compress |
				op inject |
				ConvertFrom-Json
		}
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
	} | Convert-Injectable

	foreach ($onlyPassword in $onlyPasswords | Get-Member | Where-Object MemberType -EQ "NoteProperty" | Select-Object -ExpandProperty Name) {
		Write-Verbose "Setting secret '$onlyPassword' from op"
		$password = $onlyPasswords.$onlyPassword.Password
		Set-Secret -Name $onlyPassword -SecureStringSecret ($password | ConvertTo-SecureString -AsPlainText)
	}

	$logins = @{
		BuildServer = @{
			Username = "op://CareEvolution.Infrastructure/uw4cpfxhjtzbpr7uefelhap25y/username"
			Password = "op://CareEvolution.Infrastructure/uw4cpfxhjtzbpr7uefelhap25y/password"
		}
	} | Convert-Injectable

	foreach ($login in $logins | Get-Member | Where-Object MemberType -EQ "NoteProperty" | Select-Object -ExpandProperty Name) {
		$username = $logins.$login.Username
		$password = $logins.$login.Password
		Write-Verbose "Setting secret '$login' from op '$username'"
		$secretCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($password | ConvertTo-SecureString -AsPlainText)
		Set-Secret -Name $login -Secret $secretCredential
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
	} | Convert-Injectable

	foreach ($apiCredential in $apiCredentials | Get-Member | Where-Object MemberType -EQ "NoteProperty" | Select-Object -ExpandProperty Name) {
		$username = $apiCredentials.$apiCredential.Username
		$credential = $apiCredentials.$apiCredential.Credential
		Write-Verbose "Setting secret '$apiCredential' from op '$username'"
		$secretCredential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($credential | ConvertTo-SecureString -AsPlainText)
		Set-Secret -Name $apiCredential -Secret $secretCredential
	}
}
