function Invoke-HistoryWithReplacement {
		param(
				[Parameter(Mandatory = $True)]
				[string] $String,
				[Parameter(Mandatory = $True)]
				[string] $Replacement
		)
		$lastHistory = Get-History -Count 1
		if ( $lastHistory.CommandLine -Like "*$String*" ) {
				$modified = $lastHistory.CommandLine -Replace $String, $Replacement
				Write-Host $modified
				#TODO: $lastHistory | Add-History
				Invoke-Expression -Command $modified
		} else {
				Write-Error "Cannot find '$String' in previous command."
		}

}
Set-Alias ^ Invoke-HistoryWithReplacement
