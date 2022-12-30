function ConvertTo-Base64 {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline)]
		[string]$InputObject
	)
	process {
		$bytes = [System.Text.Encoding]::UTF8.GetBytes($InputObject)
		[System.Convert]::ToBase64String($bytes)
	}
}