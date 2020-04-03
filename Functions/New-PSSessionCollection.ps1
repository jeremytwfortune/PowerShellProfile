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

			[string] $ParentPath
		)

		if ($Configuration -is [string]) {
			if ($ParentPath) {
				Write-Verbose "Creating session for $ParentPath"
			} else {
				Write-Verbose "Creating session at root"
			}
			return New-PSSession -ComputerName $Configuration -Credential $Credential
		}

		$sessions = @()
		$notePropertyChildren = $Configuration |
			Get-Member |
				? MemberType -Eq "NoteProperty" |
				Select-Object -ExpandProperty Name
		foreach ($notePropertyChild in $notePropertyChildren) {
			if ($ParentPath) {
				$path = "$ParentPath/"
			}
			$path += $notePropertyChild
			$node = $Configuration.$notePropertyChild
			Write-Verbose "Traversing to $path"
			$sessions += ConvertTo-PSSession `
				-Configuration $node `
				-Credential $Credential `
				-ParentPath $path
			$path = $null
		}

		$sessions
	}

	ConvertTo-PSSession -Configuration $Configuration -Credential $Credential
}

Set-Alias -Name nsnc -Value New-PSSessionCollection
