function Convert-TerraformPlan {
	[CmdletBinding()]
	param(
		[Parameter(ValueFromPipeline)]
		[string] $InputObject
	)
	process {
		if ($InputObject -notlike '{*') {
			return
		}
		$InputObject | ConvertFrom-Json
	}
}
