# https://gist.github.com/jermity/d38da10534a7a56af32d
function Get-StringHash {
	param(
		[Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string] $String,

		[ValidateSet("MD5", "SHA1", "SHA256", "SHA512")]
		[string] $HashName = "MD5"
	)
	$algorithm = [System.Security.Cryptography.HashAlgorithm]::Create( $HashName )
	$hashed = $algorithm.ComputeHash( [System.Text.Encoding]::UTF8.GetBytes( $String ) )
	[System.Convert]::ToHexString($hashed).ToLower()
}
