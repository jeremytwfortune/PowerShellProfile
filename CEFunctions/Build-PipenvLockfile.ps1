function Build-PipenvLockfile {
	[CmdletBinding()]
	param(
		[string] $Directory = (Get-Location).ToString(),
		[switch] $DestroyEnvironment
	)

	$buildServerEnvironment = "export PROGET_USERNAME='buildserver'; export PROGET_PASSWORD='${Env:PROGET_PASSWORD}'"
	$initialGeneration = "$buildServerEnvironment; python3 -m pipenv install --dev"
	$lock = "$buildServerEnvironment; python3 -m pipenv lock --dev --keep-outdated"

	Push-Location $Directory
	try {
		if ($DestroyEnvironment) {
			bash -c "python3 -m pipenv --rm"
		} else {
			bash -c "python3 -m pipenv clean"
		}
		bash -c $initialGeneration

		if ($DestroyEnvironment) {
			pipenv --rm
		} else {
			pipenv clean
		}
		pipenv install --dev --keep-outdated

		bash -c $lock
	} finally {
		Pop-Location
	}
}