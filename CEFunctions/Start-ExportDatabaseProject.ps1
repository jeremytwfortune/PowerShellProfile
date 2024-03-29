function Start-ExportDatabaseProject {
	[CmdletBinding()]
	param(
		[ValidateSet("Qa", "Prod")]
		[Parameter(Mandatory)]
		[string] $Environment,

		[Parameter(ValueFromPipeline)]
		[string] $ProjectName,

		[Parameter()]
		[hashtable] $ContainerEnvironment = $Null
	)

	begin {
		$functionName = "pep-mdh-export-database-TaskRun-$($Environment.ToLower())"
	}

	process {
		$payload = @{
			Records = @(
				@{
					s3 = @{ object = @{ key = "$ProjectName/manual" } }
				}
			)
		}
		if ($ContainerEnvironment) {
			$payload.Environment = $ContainerEnvironment
		}

		$jsonPayload = $payload | ConvertTo-Json -Compress -Depth 20
		Invoke-LMFunction -FunctionName $functionName -Payload $jsonPayload
	}
}
