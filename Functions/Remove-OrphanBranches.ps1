function Remove-OrphanBranches {
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact="High")]
	param()

	$deletable = git branch --format "%(refname:short) %(upstream:track)" |
		Where-Object { $_ -match '\[gone\]' } |
		ForEach-Object { $_ -split ' ' | Select-Object -First 1 }

	$deletable | ForEach-Object {
		if ($PSCmdlet.ShouldProcess($_, "Delete")) {
			git branch -D $_
		}
	}
}
