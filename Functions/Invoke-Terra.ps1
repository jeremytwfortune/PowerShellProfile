function Invoke-Terra {
	if (Test-Path "./terragrunt.hcl") {
		terragrunt @args
	}
	else {
		terraform @args
	}
}

Set-Alias t Invoke-Terra