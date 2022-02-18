function Repair-BuildServerKey {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string] $Prefix,

		[Parameter()]
		[string] $UserName = "buildserver.travis"
	)

	$repositories = @(
		"CareEvolution/GalileoE2C",
		"CareEvolution/GalileoE2CPep",
		"CareEvolution/GalileoE2CTransformers",
		"CareEvolution/GalileoE2C-AdminUI"
	)

	$Prefix = $Prefix.ToUpper()

	$currentKeys = Get-IAMAccessKey -UserName $UserName
	if ($currentKeys -gt 1) {
		throw "More than one current key for $UserName. Remove one before continuing."
	}
	$newKey = New-IAMAccessKey -UserName $UserName

	Write-Verbose "Distributing new ID $($newKey.AccessKeyId)"
	foreach ($repository in $repositories) {
		$secrets = gh secret list -R $repository | Select-String "$Prefix"
		if (-not $secrets) {
			Write-Warning "There are no secrets for $Prefix in $repository"
			continue
		}

		Write-Verbose "Setting keys in $repository"
		gh secret set -R $repository "${Prefix}_AWS_ACCESS_KEY_ID" --body $newKey.AccessKeyId
		gh secret set -R $repository "${Prefix}_AWS_SECRET_ACCESS_KEY" --body $newKey.SecretAccessKey
	}

	$currentKeys | Remove-IAMAccessKey -UserName $UserName -Confirm:$False
	$newKey
}
