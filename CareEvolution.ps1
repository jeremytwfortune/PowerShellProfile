$Global:StoredAWSCredentialPromptColor = "Magenta"

Get-ChildItem "$(Split-Path $PROFILE)\CEFunctions" | % {
	. $_.FullName
}

Set-Alias tf terraform
Set-Alias tg terragrunt
