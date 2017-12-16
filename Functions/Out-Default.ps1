function Out-Default {
	$Input | Tee-Object -Var Global:LastOutput |
		Microsoft.PowerShell.Core\Out-Default
}
