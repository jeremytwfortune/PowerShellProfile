function Invoke-GitSparklyClean {
	[CmdletBinding()] param(
		[String[]] $Excludes,
		[Switch] $DryRun
	)
	$count = 0
	$results = @( "default" )

	if ( $DryRun ) {
		$dryRunFlag = "-n"
	}
	if ( $Excludes.Count -gt 0 ) {
		foreach ( $exclude in $Excludes ) {
			$excludeCommand = "$excludeCommand -e $exclude"
		}
	}
	$defaultExclude = "-e .idea"

	$command = "git clean -xdf $defaultExclude $excludeCommand $dryRunFlag"
	Write-Verbose "Executing '$command'"

	while ( $results.Count -gt 0 ) {
		if ( $count -eq 2 ) {
			Write-Host 'ლ(ಠ益ಠლ)'
		} elseif ( $count -eq 3 ) {
			Write-Host '(╯°□°)╯︵ ┻━┻'
		}

		$results = Invoke-Expression $command
		if ( $results ) {
			Write-Verbose $results
		}
		if ( $DryRun ) {
			$results = @()
		}

		$count++
	}
}
