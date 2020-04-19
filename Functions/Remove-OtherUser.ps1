function Remove-OtherUser {
	[CmdletBinding()]
	param(
		[Parameter(ValueFromPipeline)]
		[string] $UserName
	)

	begin {
		$otherUsers = quser | ? {$_ -notmatch 'USERNAME' -and $_ -notmatch '^>'}
	}

	process {
		$otherUsers | %{
			$fields = $_.Trim() -split '\s+'
			if ($UserName -and $UserName -eq $fields[0]) {
				$sessionId = $fields[$fields.Count - 6]
				Write-Verbose "Logging off user '$($fields[0])'"
				& logoff $sessionId
			}
		}
	}
}

Set-Alias rou Remove-OtherUsers
