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
	autohotkey `
	f.lux.install `
	rainmeter

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
		citrix-receiver `
		nuget.commandline

	choco install -y nodejs --version 9.5.0
	# CE rdcman rdg file available in CE Google Drive

	Start-Process "https://www.microsoft.com/en-us/sql-server/sql-server-downloads"

	"IIS-ASPNET45",
	"Windows-Identity-Foundation",
	"WCF-HTTP-Activation",
	"WCF-HTTP-Activation45",
	"IIS-ManagementScriptingTools",
	"MSMQ-Server",
	"MSMQ-ADIntegration",
	"MSMQ-HTTP" | ForEach-Object {
		Enable-WindowsOptionalFeature -Online -FeatureName $_ -All
	}
}

Install-Module -Name PSReadLine -Force
Install-Module -Name CredentialManager -Force
