function ConvertTo-Base64 {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline)]
		[string]$InputObject,

		[Parameter()]
		[switch]$FromFileByteStream
	)
	process {
		if ($FromFileByteStream) {
			$bytes = Get-Content -Path $InputObject -AsByteStream -ReadCount 0
		}
		else {
			$bytes = [System.Text.Encoding]::UTF8.GetBytes($InputObject)
		}
		[System.Convert]::ToBase64String($bytes)
	}
}