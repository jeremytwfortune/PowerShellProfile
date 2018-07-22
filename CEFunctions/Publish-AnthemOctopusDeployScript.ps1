#Require -Version 5.1

Import-Module Octoposh
Import-Module PSFTP

function Publish-AnthemOctopusDeployScript {
	[CmdletBinding()] param (
		[Parameter(Mandatory)]
		[System.Management.Automation.Runspaces.PSSession] $Session,

		[ValidateSet("Prod", "PerfTest", "QA")]
		[String] $Tenant,

		[ValidateSet("Galileo", "Narya")]
		[String] $Project,

		[Parameter(Mandatory)]
		[String] $Version,

		[ValidateSet("Prod", "PerfTest", "QA")]
		[String] $Environment = $Tenant,

		[ValidateNotNullOrEmpty()]
		[String] $RemoteDirectory = "/Temp/Jeremy",

		[ValidateNotNullOrEmpty()]
		[String] $OctopusApiKey = $Global:CredentialStore.Tokens.OctopusApiKey,

		[ValidateNotNullOrEmpty()]
		[PSCredential] $Credential = $Global:CredentialStore.CeCorp,

		[ValidateNotNullOrEmpty()]
		[String] $FtpServer = "ftp://download.careevolution.com",

		[Switch] $KeepFiles,

		[Switch] $NoUpload
	)

	function Remove-AnthemOctopusDeployScript {
		[CmdletBinding()] param (
			$Session,
			[ValidateNotNullOrEmpty()] $EnvironmentName,
		 	$DeploymentRoot = "C:\OfflineDeploy")
		Write-Verbose "Removing server files"
		Invoke-Command -Session $Session -ArgumentList $DeploymentRoot, $EnvironmentName -ScriptBlock {
			param ( $DeploymentRoot, $EnvironmentName )
			Remove-Item "$DeploymentRoot\$EnvironmentName" -Recurse -Confirm -ErrorAction SilentlyContinue
		}
		Write-Verbose "Server files removed"
	}

	function Invoke-OctopusDeploy {
		[CmdletBinding()] param (
			$EnvironmentName,
			$TenantName,
			$OctopusApiKey,
			$ReleaseVersion,
			$ProjectName = "Galileo - Next",
			$ServerUrl = "https://octopus.careevolution.com"
		)

		Write-Verbose "Starting Octopus Deploy"

		$headers = @{
				"X-Octopus-ApiKey" = $OctopusApiKey
				"Content-Type" = "application/json"
		}
		$endpoint = "$ServerUrl/api"

		Set-OctopusConnectionInfo -Server $ServerUrl -ApiKey $OctopusApiKey
		$project = Get-OctopusProject -Name $ProjectName
		$environment = Get-OctopusEnvironment -Name $EnvironmentName
		$tenant = Get-OctopusTenant -Name $TenantName
		$release = Get-OctopusRelease -Project $project.Name -ReleaseVersion $ReleaseVersion
		if ( ! ( $project -And $environment -And $tenant -And $release ) ) {
			throw "Unable to locate some Octopus component"
		}
		$body = New-Object -TypeName PSObject -Property @{
			ReleaseId = $release.Id
			EnvironmentId = $environment.Id
			TenantId = $tenant.Id
			Comment = "Created by PowerShell script"
		} | ConvertTo-Json
		try {
			$deployment = Invoke-RestMethod `
				-Headers $headers `
				-Method Post -Uri "$endpoint/deployments" `
				-Body $body
		} catch {
			throw
		}
		while ( ! ( Invoke-RestMethod `
			-Headers $headers `
			-Method Get `
			-Uri "$endpoint/tasks/$( $deployment.TaskId )" ).IsCompleted
		) {
			Start-Sleep -Seconds 10
		}

		Write-Verbose "Octopus Deploy successful"
	}

	function Compress-OctopusDeployScript {
		[CmdletBinding()] param (
			$Session,
			$EnvironmentName,
		 	$DeploymentRoot = "C:\OfflineDeploy"
		)
		Write-Verbose "Compressing files"
		Invoke-Command -Session $Session `
			-ArgumentList `
				$DeploymentRoot, `
				$EnvironmentName `
			-ScriptBlock {
			param ( $DeploymentRoot, $EnvironmentName )
			if ( ! ( $deploymentDirectory = Get-Item "$DeploymentRoot\$EnvironmentName" ) ) {
				throw "Unable to find deployment directory"
			}
			Get-ChildItem -Path $deploymentDirectory -Directory | %{
				Write-Zip -Path $_.FullName -OutputPath "$deploymentDirectory\$($_.BaseName).zip"
			}
		}
		Write-Verbose "Files compressed"
	}

	function Send-OctopusDeployScript {
		[CmdletBinding()] param (
			$Session,
			$EnvironmentName,
			$RemoteDirectory,
			$DeploymentRoot = "C:\OfflineDeploy"
		)
		Write-Verbose "Uploading files"
		Invoke-Command -Session $Session `
			-ArgumentList `
				$DeploymentRoot, `
				$EnvironmentName, `
				$RemoteDirectory `
			-ScriptBlock {
			param (
				$DeploymentRoot,
				$EnvironmentName,
				$RemoteDirectory
			)
			if ( ! ( $deploymentDirectory = Get-Item "$DeploymentRoot\$EnvironmentName" ) ) {
				throw "Unable to find deployment directory"
			}
			$localZips = Get-ChildItem -Path "$deploymentDirectory\*.zip" -File
			Get-FtpChildItem -Path "$RemoteDirectory" | %{
				if ( $localZips.Name -Contains $_.Name ) {
					Remove-FtpItem "$($_.FullName)"
				}
			}
			Set-Location $deploymentDirectory # Send-FtpItem is bad with absolute local paths.
			$localZips | %{
				Send-FtpItem -Path $RemoteDirectory -LocalPath "$($_.Name)"
			}
		}
		Write-Verbose "Files uploaded"
	}

	$environmentName = "Anthem $Environment"
	$tenantName = "Anthem - $Tenant"
	if ( $Project -Eq "Galileo" ) {
		$projectName = "Galileo - Next"
	} else {
		$projectName = $Project
	}

	try {
		if ( ! $KeepFiles ) {
			Remove-AnthemOctopusDeployScript -Session $Session -EnvironmentName $environmentName
		}
		Invoke-OctopusDeploy `
			-EnvironmentName $environmentName `
			-TenantName $tenantName `
			-OctopusApiKey $OctopusApiKey `
			-ReleaseVersion $Version `
			-ProjectName $projectName
		Invoke-Command -Session $Session -ArgumentList $Credential, $FtpServer -ScriptBlock {
			param( $Credential, $Server )
			Set-FTPConnection `
				-Server $Server `
				-Credentials $Credential `
				-EnableSsl `
				-IgnoreCert `
				-UsePassive
		} -ErrorAction Stop
		Compress-OctopusDeployScript -Session $Session -EnvironmentName $environmentName
		if ( ! ( $NoUpload ) ) {
			 Send-OctopusDeployScript `
				-Session $session `
				-EnvironmentName $environmentName `
				-RemoteDirectory $RemoteDirectory
		}
	} catch {
		throw
	}

}
