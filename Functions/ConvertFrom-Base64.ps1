function ConvertFrom-Base64 {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline)]
		[string]$InputObject
	)
	process {
		$bytes = [System.Convert]::FromBase64String($InputObject)
		[System.Text.Encoding]::UTF8.GetString($bytes)
	}
}