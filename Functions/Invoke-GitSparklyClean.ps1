function Invoke-GitSparklyClean {
	$count = 0
	$results = 1
	while ( $results -gt 0 ) {
		if ( $count -eq 2 ){
			Write-Host '(╯°□°)╯︵ ┻━┻'
		} elseif ( $count -eq 3 ) {
			Write-Host 'ლ(ಠ益ಠლ)'
		}
		$results = (git clean -xdf).Count
		$count++
	}
}
