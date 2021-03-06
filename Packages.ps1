param (
	[ValidateSet("Home", "Work", "WorkSpace")]
	$Work
)

Set-ExecutionPolicy Bypass; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install -y `
	googlechrome `
	powershell-core `
	microsoft-windows-terminal `
	vscode `
	7zip `
	git `
	ag `
	gpg4win `
	vim `

refreshenv

Install-Module -Name "Microsoft.PowerShell.SecretManagement" -AllowPrerelease
Install-Module -Name "AWS.Tools.Installer"
Install-Module -Name PSReadLine -Force
Install-Module -Name PowerLine

Install-AWSToolsModule -Name `
	AWS.Tools.CloudWatchLogs, `
	AWS.Tools.Common, `
	AWS.Tools.EC2, `
	AWS.Tools.ECS, `
	AWS.Tools.IdentityManagement, `
	AWS.Tools.Lambda, `
	AWS.Tools.Redshift, `
	AWS.Tools.S3, `
	AWS.Tools.SecretsManager, `
	AWS.Tools.SecurityToken, `
	AWS.Tools.SimpleNotificationService, `
	AWS.Tools.WorkSpaces

Copy-Item "$PSScriptRoot\ProgramList.txt" $HOME
Copy-Item "$PSScriptRoot\AwsAssumableRoles.txt" $HOME
Copy-Item "$PSScriptRoot\global.gitconfig" "$HOME\.gitconfig"
"{}" | Out-File "$Home\CeServers.json"

if ( $Machine -in ("Work", "Home") ) {
	choco install -y `
		autohotkey `
		office365proplus `
		f.lux.install `
		rainmeter `
		windirstat `
		greenshot `
		slack `
		gimp `
		licecap `

	Copy-Item "$PSScriptRoot\wt-admin.lnk" $HOME
	Copy-Item "$PSScriptRoot\AutoHotKey.ahk" "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
}

if ( $Machine -eq "Work" ) {
	choco install -y `
		amazon-workspaces `
		visualstudio2019enterprise `
		citrix-receiver `
		nuget.commandline `
		dotnetcore-sdk `
		ssms

	choco install -y nodejs --version 12.19.0

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

if ( $Machine -eq "WorkSpace") {
	choco uninstall -y `
		aws-vault `
		awscli `
		filezilla `
		gitextensions `
		GPMC `
		linqpad `
		notepadplusplus `
		rdmfree `
		rdtabs `
		putty
}