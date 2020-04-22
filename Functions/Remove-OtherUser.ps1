function Remove-OtherUser {
	[CmdletBinding()]
	param()

	quser |
		? {$_ -notmatch 'USERNAME' -and $_ -notmatch '^>'} |
		%{
			$fields = $_.Trim() -split '\s+'
			$sessionId = $fields[$fields.Count - 6]
			Write-Verbose "Logging off user '$($fields[0])'"
			& logoff $sessionId
		}
}

Set-Alias rou Remove-OtherUser
