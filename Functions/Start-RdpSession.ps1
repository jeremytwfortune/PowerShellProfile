function Start-RdpSession {
	[CmdletBinding()] param (
		[Parameter(
			Mandatory,
			Position = 1,
			ValueFromPipeline
		)]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.Runspaces.PSSession[]] $Session,

		[PSCredential] $Credential
	)

	begin {
		function Start-SingleSession {
			param(
				[System.Management.Automation.Runspaces.PSSession] $SingleSession,
				[PSCredential] $SingleCredential
			)
			$computerName = $SingleSession.ComputerName
			$cred = $SingleCredential ?? $SingleSession.Runspace.ConnectionInfo.Credential
			if ( ( -Not $computerName ) -Or ( -Not $cred ) ) {
				throw "Unable to determine ComputerName or Credential from Session"
			}

			Write-Verbose "Setting credential for $computerName"
			Set-Secret -Name "TERMSRV/$computerName" -SecureStringSecret $cred.Password

			Write-Verbose "Starting connection for $computerName"
			Invoke-Expression "mstsc /v:$computerName"
			# Invoke-Expression "cmdkey /delete:TERMSRV/$computerName"
		}

		$fromPipeline = -Not $PSBoundParameters.ContainsKey( "Session" )
	}
	process {
		if ( $fromPipeline ) {
			Start-SingleSession -SingleSession $_ -SingleCredential $Credential
		} else {
			$Session | %{
				Start-SingleSession -SingleSession $_ -SingleCredential $Credential
			}
		}
	}
}
