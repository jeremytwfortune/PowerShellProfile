function Select-TerragruntLocation {
	[OutputType([string])]
	[CmdletBinding()]
	param(
		[Parameter(ValueFromPipeline)]
		[string]$Path = ".",

		[Parameter()]
		[switch]$VariableFile
	)

	process {
		if (-not (Test-Path -Path $Path)) {
			Write-Error -Message "The path '$Path' does not exist."
			return
		}

		$fullPath = Resolve-Path -Path $Path | Get-Item
		if (Test-Path -Path $fullPath -PathType Container) {
			$fullPath = Get-ChildItem -Path $fullPath -Filter "terragrunt.hcl" | Select-Object -First 1
		}

		if (-not $fullPath) {
			Write-Error -Message "The path '$Path' does not contain a terragrunt.hcl file."
			return
		}

		$terragrunt = Get-Content -Path $fullPath -Raw
		$reference = $terragrunt |
			Select-String -Pattern "terraform\s{\s+source\s*=\s*`"(.*?)`"\s*}" |
			ForEach-Object {
				$_.Matches.Groups[1].Value
			}

		$resolvedPath = Resolve-Path `
			-Path $reference `
			-RelativeBasePath $fullPath.DirectoryName `
			-ErrorAction SilentlyContinue

		if ($resolvedPath) {
			$relativeResolved = $resolvedPath |
				Get-Item |
				Resolve-Path -Relative
			if (-Not $VariableFile) {
				return $relativeResolved
			}

			return Get-ChildItem -Path $resolvedPath -Filter "variable*.tf" |
				Select-Object -First 1 |
				Resolve-Path -Relative
		}

		$reference
	}
}

Set-Alias -Name stl -Value Select-TerragruntLocation
