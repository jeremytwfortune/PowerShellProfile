function Start-RdpSession {
	[CmdletBinding()] param (
		[Parameter( Mandatory )]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.Runspaces.PSSession[]] $Session,

		[PSCredential] $Credential
	)

	$Targets = @( $Session ) | %{
		@{
			ComputerName = $_.ComputerName
			Credential = if ( $Credential ) { $Credential } else { $_.Runspace.ConnectionInfo.Credential }
		}
	}
	$Targets | %{
		Write-Verbose "Setting credential for $_"
		$pass = $_.Credential.GetNetworkCredential().Password -Replace "'", "''"
		Invoke-Expression "cmdkey /generic:TERMSRV/$($_.ComputerName) /user:$($_.Credential.UserName) /pass:'$pass'" 1>$Null

		Write-Verbose "Starting connection for $($_.ComputerName)"
		Invoke-Expression "mstsc /v:$($_.ComputerName)"
	}
}
