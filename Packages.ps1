param (
	[ValidateSet("Home", "Work", "WorkSpace")]
	$Machine
)

"Microsoft.PowerShell",
"Microsoft.VisualStudioCode",
"Git.Git",
"7zip.7Zip" | ForEach-Object {
	winget install $_
}

refreshenv

Install-Module -Name "Microsoft.PowerShell.SecretManagement" -AllowPrerelease
Install-Module -Name "Microsoft.PowerShell.SecretStore" -AllowPrerelease
Install-Module -Name "AWS.Tools.Installer"
Install-Module -Name PSReadLine -Force
Install-Module -Name PowerLine -AllowClobber

Set-SecretStoreConfiguration
Register-SecretVault `
	-Name SecretStore `
	-ModuleName Microsoft.PowerShell.SecretStore `
	-DefaultVault

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
	AWS.Tools.WorkSpaces, `
	AWS.Tools.SSO, `
	AWS.Tools.SSOOIDC


Copy-Item "$PSScriptRoot\global.gitconfig" "$HOME\.gitconfig"

if ( $Machine -in ("Work", "Home") ) {
	"AutoHotkey.AutoHotkey",
	"flux.flux",
	"Rainmeter.Rainmeter",
	"ShareX.ShareX",
	"SlackTechnologies.Slack",
	"GIMP.GIMP",
	"LICEcap.LICEcap",
	"ag.ag",
	"Gpg4win.Gpg4win",
	"GnuPG.Gpg4win",
	"Vim.Vim",
	"Microsoft.PowerToys" | ForEach-Object {
		winget install $_
	}

	Copy-Item "$PSScriptRoot\wt-admin.lnk" $HOME
	Copy-Item "$PSScriptRoot\AutoHotKey.ahk" "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
}

if ( $Machine -eq "Work" ) {
	"Amazon.WorkspacesClient",
	"Microsoft.VisualStudio.2019.Professional",
	"Microsoft.VisualStudio.2022.Professional",
	"Microsoft.NuGet",
	"Microsoft.DotNet.SDK.7",
	"Microsoft.SQLServerManagementStudio",
	"OpenJS.NodeJS.LTS" | ForEach-Object {
		winget install $_
	}

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
		filezilla `
		gitextensions `
		GPMC `
		linqpad `
		notepadplusplus `
		rdmfree `
		rdtabs `
		putty

	choco install -y conemu
}