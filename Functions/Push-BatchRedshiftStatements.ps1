function Push-BatchRedshiftStatements {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string] $Database,
		[Parameter(Mandatory)]
		[string] $Arn,

		[Parameter(Mandatory)]
		[string] $File,

		[Parameter(ParameterSetName = "Provisioned")]
		[string] $Cluster,
		[Parameter(ParameterSetName = "Serverless")]
		[string] $Workgroup,

		[int] $BatchSize = 30
	)

	function Invoke-BatchRedshiftStatements {
		param(
			[string] $Cluster,
			[string] $Workgroup,
			[string] $Database,
			[string] $Arn,
			[string[]] $Statements
		)

		if ($Statements.Length -eq 0) {
			return
		}

		Write-Verbose "Pushing: $($Statements -join '`n')"

		if ($Cluster) {
			Push-RSDBatchStatement `
				-SecretArn $Arn `
				-Sql $batch `
				-Database $Database `
				-Cluster $Cluster
			return
		}
		Push-RSDBatchStatement `
			-SecretArn $Arn `
			-Sql $batch `
			-Database $Database `
			-Workgroup $Workgroup
	}

	if (-not (Test-Path $File)) {
		throw "File not found: $File"
	}

	$statements = (Get-Content $File -Raw) -split ';' |
		ForEach-Object { $_ + ";" } |
		Select-Object -SkipLast 1

	0..($statements.Length / $BatchSize) |
		ForEach-Object {
			$start = $_ * $BatchSize
			$end = $start + ($BatchSize - 1)
			$batch = $statements[$start..$end]

			Invoke-BatchRedshiftStatements `
				-Cluster $Cluster `
				-Workgroup $Workgroup `
				-Database $Database `
				-Arn $Arn `
				-Statements $batch
		}
}
