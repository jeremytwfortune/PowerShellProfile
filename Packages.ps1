Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install -y `
	7zip `
	notepadplusplus `
	atom `
	chrome `
	git `
	ag `
	gpg4win `
	gimp `
	licecap `
	greenshot `
	windirstat `
	conemu `

Install-Module PSReadLine
Install-Module CredentialManager
