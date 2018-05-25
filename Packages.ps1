param ( [Switch] $Work )

Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install -y `
	7zip `
	notepadplusplus `
	atom `
	googlechrome `
	git `
	ag `
	gpg4win `
	gimp `
	licecap `
	greenshot `
	windirstat `
	conemu `
	dashlane `
	office365proplus `
	vim `
	autohotkey

if ( $Work ) {
	choco install -y `
		visualstudio2017enterprise `
		dbeaver `
		sql-server-management-studio `
		jetbrains-rider `
		filezilla `
		rdcman `
		r.studio `
		slack `
		citrix-receiver

	# CE rdcman rdg file available in CE Google Drive
}


Install-Module -Name PSReadLine -Force
Install-Module -Name CredentialManager -Force
