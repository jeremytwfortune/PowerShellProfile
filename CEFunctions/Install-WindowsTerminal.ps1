function Install-WindowsTerminal {
	param(
		[Parameter(Mandatory)]
		[string] $MsixBundleUri  # Find this on https://github.com/microsoft/terminal/releases/latest
	)
	nuget sources add -Name nuget.org -Source https://api.nuget.org/v3/index.json
	$workingDirectory = New-Item -Path "$Home\TerminalInstall" -ItemType Directory -Force

	$localMsix = "$workingDirectory\windows.terminal.msixbundle"
	iwr -Uri $MsixBundleUri -OutFile $localMsix

	nuget install Microsoft.UI.Xaml -OutputDirectory $workingDirectory

	$xamlInstallDir = Get-ChildItem $workingDirectory -Filter "Microsoft.UI.Xaml*" -Directory | select -First 1
	$xamlAppx = Get-ChildItem "$($xamlInstallDir.FullName)\tools\AppX\x64\Release\" -Filter "Microsoft.UI.Xaml*" | select -First 1
	Add-AppxPackage $xamlAppx.FullName
	Add-AppxPackage $localMsix

	Remove-Item $workingDirectory -Recurse -Force
}
