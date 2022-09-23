foreach ($module in "SSO", "SSOOIDC") {
	$toolsDirectory = Get-ChildItem "$((Get-Item $PROFILE).Directory)\Modules\AWS.Tools.$module" |
		Sort-Object LastWriteTime -Descending |
		Select-Object -First 1
	$dll = "$toolsDirectory\AWSSDK.${module}.dll"
	if ( Test-Path $dll ) {
		Add-Type -Path $dll
	}
}

Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | % {
	. $_.FullName
}

Set-AwsDefaultRegion -Region "us-east-1"

Set-Alias tf terraform
Set-Alias tg terragrunt
