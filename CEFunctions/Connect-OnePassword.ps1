function Connect-OnePassword {
	[CmdletBinding()]
	param()

	try {
		$vaultResponse = op vault list 2>&1
		if ($vaultResponse -like '*ERROR*') {
			Write-Verbose "No active login for op; signing in."
			$Env:OP_SESSION_careevolution = Get-Secret "1Password" |
				ConvertFrom-SecureString -AsPlainText |
				op signin --account careevolution --raw
		}
		else {
			Write-Verbose "Using existing login for op."
		}
	}
 catch {
		$Env:OP_SESSION_careevolution = ""
		return $False
	}
	$True
}