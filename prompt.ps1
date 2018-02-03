function prompt {
	function Get-ShortPath {
		param (
			[string] $Path,
			[hashtable] $ShortcutDirectories = @{
				Home = $Home;
				Work = $Work;
				Desk = $Desk;
				Drive = $Drive;
				Repos = $Repos
			}
		)
		if ( $shortcuts = $ShortcutDirectories.GetEnumerator() | ? { "$Path*" -Like "$($_.Value)*" } ) {
			$shortcut = $shortcuts | Sort-Object -Property Value -Descending | Select-Object -First 1 # Hacky
			$Path -Replace [regex]::Escape("$($shortcut.Value)"), "$($shortcut.Name)"
		} else {
			$Path -Replace [regex]::Escape("Microsoft.PowerShell.Core\FileSystem::"), ""
		}
	}

	if ( ! $Global:DirectoryHistory ) {
		$Global:DirectoryHistory = @()
	}
	if ( ( $Global:DirectoryHistory.Count -Gt 0 -And $Global:DirectoryHistory[$Global:DirectoryHistory.Count - 1].Path -Ne ( Get-Location ).Path ) -Or ( $Global:DirectoryHistory.Count -Eq 0 ) ) {
		$Global:DirectoryHistory += ( Get-Location )
	}

	Write-Host ""

	Write-Host "$Env:USERNAME@$Env:USERDOMAIN " -NoNewline -ForegroundColor Magenta
	Write-Host "$(Get-ShortPath -Path (Get-Location)) " -NoNewline -ForegroundColor Cyan

	try {
		$insideRepo = git rev-parse --is-inside-work-tree
		if ( ! ( $headReference = git symbolic-ref --short HEAD 2>$Null ) ) {
			$headReference = (git rev-parse HEAD 2>$Null).Substring(0, 8)
		}
		Write-Host $headReference -NoNewline -ForegroundColor DarkGreen
	} catch {}

	Write-Host ""
	Write-Host ">" -NoNewline
	return " "
}
