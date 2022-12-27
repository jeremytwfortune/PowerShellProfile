function Select-AWSProperties {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory)]
		[string[]]$Properties,

		[Parameter(Mandatory, ValueFromPipeline)]
		[object[]]$InputObject
	)

	process {
		$tagSelectable = $Properties | Where-Object { $_ -like 'Tags.*' } | ForEach-Object { $_.Substring(5) }
		$directlySelectable = $Properties | Where-Object { $_ -notlike 'Tags.*' }
		$tagExpressions = foreach ($tag in $tagSelectable) {
			@{
				Label = $tag
				Expression = { $_.Tags | Where-Object { $_.Key -eq $tag } | Select-Object -ExpandProperty Value }
			}
		}
		$selections = @() + $directlySelectable + $tagExpressions
		$InputObject | Select-Object -Property $selections
	}

}

Set-Alias -Name sawp -Value Select-AWSProperties
