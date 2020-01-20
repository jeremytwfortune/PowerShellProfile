function New-PSSessionCollection {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[PSCustomObject] $Configuration,

		[Parameter(Mandatory)]
		[PSCredential] $Credential
	)

	function ConvertTo-PSSession {
		param(
			[Parameter(Mandatory)]
			[PSCustomObject] $Configuration,

			[Parameter(Mandatory)]
			[PSCredential] $Credential,

			[string] $Path
		)

		$sessions = @()
		$notePropertyChildren = $Configuration |
			Get-Member |
			? MemberType -Eq "NoteProperty" |
			Select-Object -ExpandProperty Name
		foreach($notePropertyChild in $notePropertyChildren) {
			if ($ParentPath) {
				$path = "$ParentPath/"
			}
			$path += $notePropertyChild
			$node = $Configuration.$notePropertyChild
			if ($node -is [string] ) {
				Write-Verbose "Creating session for $path"
				$sessions += New-PSSession -ComputerName $node -Credential $Credential
			} else {
				Write-Verbose "Traversing down to $path"
				$sessions += ConvertTo-PSSession `
					-Configuration $node `
					-Credential $Credential `
					-Path $path
			}
			$path = $null
		}

		$sessions
	}

	ConvertTo-PSSession -Configuration $Configuration -Credential $Credential
}

New-Alias -Name nsnc -Value New-PSSessionCollection
