function ConvertFrom-Base64 {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline)]
		[string]$InputObject,

		[Parameter()]
		[switch]$AsByteStream
	)
	process {
		$bytes = [System.Convert]::FromBase64String($InputObject)
		if ($AsByteStream) {
			return $bytes
		}
		[System.Text.Encoding]::UTF8.GetString($bytes)
	}
}