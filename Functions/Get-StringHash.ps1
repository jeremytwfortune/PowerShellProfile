# https://gist.github.com/jermity/d38da10534a7a56af32d
function Get-StringHash {
	param(
		[Parameter(Mandatory = $True, ValueFromPipeline, ValueFromPipelineByPropertyName)][string] $String,
		[string] $HashName = "MD5"
	)
	$StringBuilder = New-Object System.Text.StringBuilder
	[System.Security.Cryptography.HashAlgorithm]::Create( $HashName ).ComputeHash( [System.Text.Encoding]::UTF8.GetBytes( $String ) ) | %{
		[Void]$StringBuilder.Append( $_.ToString( "x2" ) )
	}
	$StringBuilder.ToString()
}
