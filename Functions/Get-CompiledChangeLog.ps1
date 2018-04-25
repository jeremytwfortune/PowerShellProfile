#Require -Version 5.1

Import-Module PSFTP

function Get-CompiledChangeLog {
	[CmdletBinding()] param(
		[Parameter( Mandatory )]
		[System.Version] $FromVersion,

		[Parameter( Mandatory )]
		[System.Version] $ToVersion,

		[ValidateNotNullOrEmpty()]
		[String] $RepositoryLocation = "C:\Users\Jeremy\Desktop",

		[ValidateNotNullOrEmpty()]
		[Parameter( ParameterSetName = "Ftp" )]
		[PSCredential] $Credential,

		[Parameter( ParameterSetName = "Local" )]
		[Switch] $Local
	)

	$VersionDiffFileSuffix = ".diff.xml"

	class VersionDiff {
		[System.Version] $From
		[System.Version] $To
		[PSObject] $Diff
		[PSObject] $Next

		SetNext( [DiffRepository] $DiffRepository ) {
			if ( ! ( $DiffRepository.VersionDiffs.From | ? { $_ -Ge $this.To } ) ) {
				return
			}

			$nextPossible = $DiffRepository.VersionDiffs | ? { $_.From -Eq $this.To }
			if ( $nextPossible -Eq $Null ) {
				Write-Warning "No patch found from $( $this.To )"
				$nextPossible = $DiffRepository.VersionDiffs | ? { $_.From -Gt $this.To }
				$nextAvailableFrom = $nextPossible.From | Sort-Object | Select-Object -Unique -First 1
				$nextPossible = $nextPossible | ? { $_.From -Eq $this.To }
			}

			$nextVersionDiff = $nextPossible | Sort-Object -Property To | Select-Object -First 1
			$this.Next = New-Object -Type PSObject -Property @{
				From = $nextVersionDiff.From
				To = $nextVersionDiff.To
			}
		}

		[String] ToString() {
			$description = "$($this.From) -> $($this.To)"
			if ( $this.Next ) {
				$description = "$description; Next Diff: $($this.Next.From) -> $($this.Next.To)"
			}
			return $description
		}

		[int] FindLength( [DiffRepository] $DiffRepository ) {
			$length = 0
			$nextDiff = $this
			while ( $nextDiff = $nextDiff.GetNext( $DiffRepository ) ) {
				$length++
			}
			return $length
		}

		[VersionDiff] GetNext( [DiffRepository] $DiffRepository ) {
			if ( ! $this.Next ) {
				return $Null
			}
			return $DiffRepository.VersionDiffs | ? { $_.From -Eq $this.Next.From -And $_.To -Eq $this.Next.To }
		}
	}

	class DiffRepository {
		DiffRepository(
			[VersionDiff[]] $VersionDiffs,
			[System.Version] $From,
			[System.Version] $To
		) {
			$this.VersionDiffs = $VersionDiffs
			$this.From = $From
			$this.To = $To

			$this.Trim()
			if ( $this.VersionDiffs ) {
				$this.SetVersionDiffNexts()
			}
		}

		[VersionDiff[]] $VersionDiffs
		[System.Version] $From
		[System.Version] $To

		Trim() {
			$this.VersionDiffs = $this.VersionDiffs | ? { $_.From -Ge $this.From -And $_.To -Le $this.To }
		}

		SetVersionDiffNexts() {
			$this.VersionDiffs | % { $_.SetNext( $this ) }
		}

		[String] ToString() {
			return "$($this.From) -> $($this.To); VersionDiffs: $($this.VersionDiffs.Count)"
		}

		[VersionDiff[]] FindLog() {
			$versionDiffLength = $this.VersionDiffs | %{
				New-Object -Type PSObject -Property @{
					VersionDiff = $_
					Length = $_.FindLength( $this )
				}
			}
			$longestVersionDiff = @()
			$currentVersionDiff = ( $versionDiffLength | Sort-Object -Property Length -Descending | Select-Object -First 1 ).VersionDiff
			$longestVersionDiff += $currentVersionDiff
			while ( $currentVersionDiff.Next ) {
				$currentVersionDiff = $currentVersionDiff.GetNext( $this )
				$longestVersionDiff += $currentVersionDiff
			}
			return $longestVersionDiff
		}
	}

	function Get-VersionDiffsFromFileRepository {
		param(
			[ScriptBlock] $GetItemNamesInFileRepository,
			[ScriptBlock] $GetFileRepositoryItemPath
		)

		$VersionDiffs = @()
		$GetItemNamesInFileRepository.Invoke() | ? {
			$_.Name -Like "*$VersionDiffFileSuffix"
		} | % {
			Write-Host $GetFileRepositoryItemPath.Invoke( $_ )
			$split = $_.Name -Replace $VersionDiffFileSuffix, "" -Split "\.\."
			$VersionDiff = New-Object VersionDiff
			$VersionDiff.From = $split[0]
			$VersionDiff.To = $split[1]
			$VersionDiff.Diff = Import-CliXml $GetFileRepositoryItemPath.Invoke( $_ )
			$VersionDiffs += $VersionDiff
		}

		$VersionDiffs
	}

	$getItemNamesInDirectory = [ScriptBlock] {
		Get-ChildItem $RepositoryLocation
	}
	$getDirectoryItemPath = [ScriptBlock] {
		param( [System.IO.FileInfo] $File ) {
			Write-Host $File.FullName
			$File.FullName
		}
	}
	$getItemNamesInFtp = [ScriptBlock] {

	}
	$getFtpItemPath = [ScriptBlock] {

	}

	if ( $Local ) {
		$versionDiffs = Get-VersionDiffsFromFileRepository `
			-GetItemNamesInFileRepository $getItemNamesInDirectory `
			-GetFileRepositoryItemPath $getDirectoryItemPath
	} else {
		$versionDiffs = Get-VersionDiffsFromFileRepository `
			-GetItemNamesInFileRepository $getItemNamesInFtp `
			-GetFileRepositoryItemPath $getFtpItemPath
	}

	$diffRepository = [DiffRepository]::New( $versionDiffs, $FromVersion, $ToVersion )
	$diffs = $diffRepository.FindLog()
	$log = @()
	$diffs | Sort-Object -Property From | %{
		$log += $diffs.Diff
	}
	$log
}
