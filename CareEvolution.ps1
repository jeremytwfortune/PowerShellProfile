Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | % {
	. $_.FullName
}

$Env:TERRAGRUNT_DOWNLOAD = "$Home\.terragrunt-cache"

Set-AwsDefaultRegion -Region "us-east-1"

Set-Alias tf terraform
Set-Alias tg terragrunt
