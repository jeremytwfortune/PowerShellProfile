function Invoke-GitSparklyClean {
	param(
		[String] $Exclude
	)
	$count = 0
	$results = 1
	while ( $results -gt 0 ) {
		if ( $count -eq 2 ){
			Write-Host '(╯°□°)╯︵ ┻━┻'
		} elseif ( $count -eq 3 ) {
			Write-Host 'ლ(ಠ益ಠლ)'
		}
		if ( $Exclude ) {
			$results = ( git clean -xdfe $Exclude ).Count
		} else {
			$results = ( git clean -xdf ).Count
		}
		$count++
	}
}
