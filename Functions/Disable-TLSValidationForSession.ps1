function Disable-TLSValidationForSession {
	[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
}
