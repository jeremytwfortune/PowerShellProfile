function New-Password {
	[CmdletBinding()]
	param(
		[int] $Length = 32,
		[char[]] $CharacterSet = (33..126 | ForEach-Object { [char]$_ })
	)

	(1..$Length | ForEach-Object { $CharacterSet | Get-Random }) -join ""
}