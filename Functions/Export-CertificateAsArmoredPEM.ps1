function Export-CertificateAsArmoredPEM {
	[CmdletBinding()]
	param(
		[Parameter()]
		[switch] $PrivateKey,

		[Parameter()]
		[switch] $Rsa,

		[Parameter(Mandatory, ValueFromPipeline)]
		[object] $PfxData
	)

	begin {
		$pfxFile = New-TemporaryFile
		$pemFile = New-TemporaryFile
		$outputFile = New-TemporaryFile
	}

	process {
		$pfxFile, $pemFile, $outputFile | ForEach-Object { "" | Out-File $_.FullName }

		$random = Get-Random
		$PfxData | Export-PfxCertificate -FilePath $pfxFile.FullName -Password ($random | ConvertTo-SecureString -Force -AsPlainText) | Out-Null

		if ($PrivateKey) {
			openssl pkcs12 -in $pfxFile.FullName -out $pemFile.FullName -nodes -nocerts -passin pass:$random
		}
		else {
			openssl pkcs12 -in $pfxFile.FullName -out $pemFile.FullName -nodes -passin pass:$random
		}

		if ($Rsa -And $PrivateKey) {
			openssl rsa -in $pemFile.FullName -out $outputFile.FullName > $Null 2>&1
		}

		if ($Rsa -And (-Not $PrivateKey)) {
			openssl rsa -in $pemFile.FullName -pubout -out $outputFile.FullName > $Null 2>&1
		}

		if ((-Not $Rsa) -And $PrivateKey) {
			Copy-Item $pemFile.FullName $outputFile.FullName -Force
		}

		if ((-Not $Rsa) -And (-Not $PrivateKey)) {
			openssl x509 -in $pemFile.FullName -out $outputFile.FullName
		}

		Get-Content $outputFile.FullName
	}

	end {
		Remove-Item $pfxFile -Force | Out-Null
		Remove-Item $pemFile -Force | Out-Null
		Remove-Item $outputFile -Force | Out-Null
	}
}
