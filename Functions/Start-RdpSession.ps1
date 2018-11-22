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
								[System.Management.Automation.Runspaces.PSSession[]] $SingleSession,
								[PSCredential] $SingleCredential
						)
						$computerName = $SingleSession.ComputerName
						$cred = if ( $SingleCredential ) { $SingleCredential } else { $SingleSession.Runspace.ConnectionInfo.Credential }
						if ( ( -Not $computerName ) -Or ( -Not $cred ) ) {
								throw "Unable to determine ComputerName or Credential from Session"
						}

						Write-Verbose "Setting credential for $computerName"
						$pass = $cred.GetNetworkCredential().Password -Replace "'", "''"
						Invoke-Expression "cmdkey /generic:TERMSRV/$computerName /user:$($cred.UserName) /pass:'$pass'" 1>$Null

						Write-Verbose "Starting connection for $computerName"
						Invoke-Expression "mstsc /v:$computerName"
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
		end {}
}
