function Build-PipenvLockfile {
	[CmdletBinding()]
	param(
		[string] $Directory = (Get-Location).ToString(),
		[switch] $DestroyEnvironment
	)

	$buildServerEnvironment = "export PROGET_USERNAME='buildserver'; export PROGET_PASSWORD='${Env:PROGET_PASSWORD}'"
	$removeEnvironment = "$buildServerEnvironment; pipenv --rm"
	$cleanEnvironment = "$buildServerEnvironment; pipenv clean"
	$initialGeneration = "$buildServerEnvironment; pipenv install --dev"
	$lock = "$buildServerEnvironment; pipenv lock --dev --keep-outdated"

	Push-Location $Directory
	try {
		Write-Verbose "Installing linux"
		if ($DestroyEnvironment) {
			bash -c $removeEnvironment
		} else {
			bash -c $cleanEnvironment
		}
		bash -c $initialGeneration

		Write-Verbose "Installing windows with --keep-outdated"
		if ($DestroyEnvironment) {
			pipenv --rm
		} else {
			pipenv clean
		}
		pipenv install --dev --keep-outdated

		Write-Verbose "Locking linux"
		bash -c $lock
	} finally {
		Pop-Location
	}
}