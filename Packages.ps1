param ( [Switch] $Work )

Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install -y `
	googlechrome `
	powershell-core `
	microsoft-windows-terminal `
	dashlane `
	vscode `
	7zip `
	git `
	slack `
	ag `
	gpg4win `
	gimp `
	licecap `
	greenshot `
	windirstat `
	office365proplus `
	vim `
	autohotkey `
	f.lux.install `
	rainmeter

refreshenv
code --install-extension Shan.code-settings-sync

Copy-Item "$PSScriptRoot\wt-admin.lnk" $HOME
Copy-Item "$PSScriptRoot\AutoHotKey.ahk" "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

if ( $Work ) {
	choco install -y `
		visualstudio2019enterprise `
		sql-server-management-studio `
		rdcman `
		r.studio `
		citrix-receiver `
		nuget.commandline `
		dotnetcore-sdk

	choco install -y nodejs --version 12.19.0
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
Install-Module -Name PowerLine
