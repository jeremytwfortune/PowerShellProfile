<#

  .SYNOPSIS

  Builds and starts Galileo and Narya on different ports.

  .DESCRIPTION

  Assumes that Galileo and Narya are downloaded, though it is not necessary to have git installed. Setting $Env:GALILEO_REPO and $Env:NARYA_REPO to the paths where these reositories are located is recommended. The repositories should have the branches checked out that will be built and started--this cmdlet does not handle repo versioning.

  .PARAMETER GalileoRepoLocation

  The directory where Galileo is located.

  .PARAMETER NaryaRepoLocation

  The directory where Narya is located.

  .PARAMETER IISExpressBinary

  The full path to the IIS Express binary to be used. Defaults to "C:\Program Files (x86)\IIS Express\iisexpress.exe"

  .PARAMETER Build

  Switch to build in addition to hosting.

  .PARAMETER SkipNarya

  Do not host or build Narya.

  .PARAMETER SkipGalileo

  Do not host or build Galileo.

  .EXAMPLE

  Build and start Galileo and Narya without $Env: variables set
  Start-LocalContentDev -GalileoRepoLocation C:\User\You\Documents\Galileo -NaryaRepoLocation C:\User\You\Documents\Narya

  .EXAMPLE

  Build and start Galileo and Narya with $Env: variables set
  Start-LocalContentDev

  .EXAMPLE

  Just start. Presumes that some building has been previously done.
  Start-LocalContentDev -NoBuild

#>
#function Start-LocalContentDev {
#  param(
#    [string] $GalileoRepoLocation = $Env:GALILEO_REPO,
#    [string] $NaryaRepoLocation = $Env:NARYA_REPO,
#    [string] $IISExpressBinary = 'C:\Program Files (x86)\IIS Express\iisexpress.exe',
#    [switch] $Build,
#    [switch] $SkipGalileo,
#    [switch] $SkipNarya
#  )
#
#  function Stop-ContentDevJobs {
#    foreach ( $jobName in ( 'Galileo', 'GalileoGrunt', 'GalileoBuild', 'GalileoClean', 'Narya', 'NaryaApi', 'NaryaBuild', 'NaryaClean' ) ) {
#      Stop-Job -Name $jobName > $Null 2>&1
#      Remove-Job -Name $jobName > $Null 2>&1
#    }
#  }
#
#  function Get-CsprojIISConfig {
#    param(
#      [Parameter( Mandatory = $True )]
#      [string] $Csproj
#    )
#    [hashtable] $config = @{}
#    [xml] $csprojXml = Get-Content "$Csproj"
#    $config.Url = $csprojXml.Project.ProjectExtensions.VisualStudio.FlavorProperties.WebProjectProperties.IISUrl
#    $config.Port = [regex]::match( $config.Url, 'localhost\:(\d+)' ).Groups[1].Value
#    return $config
#  }
#
#  foreach ( $repo in ( "$GalileoRepoLocation", "$NaryaRepoLocation" ) ) {
#    if( ! ( Test-Path $repo ) ) {
#      Write-Error "$repo does not exist."
#      return 1
#    }
#  }
#
#  $GalileoRepoLocation = $GalileoRepoLocation.TrimEnd("\")
#  $NaryaRepoLocation = $NaryaRepoLocation.TrimEnd("\")
#
#  foreach ( $command in ( "yarn", "npm" ) ) {
#    if ( ! ( Get-Command $command -ErrorAction SilentlyContinue ) ) {
#      Write-Error "$command not installed."
#      return 1
#    }
#  }
#
#  $naryaConfigOverride = "$NaryaRepoLocation\NaryaApi\config.json.override"
#  if ( ! ( Test-Path $naryaConfigOverride ) ) {
#    Write-Warning "$naryaConfigOverride not found!"
#  }
#
#  Stop-ContentDevJobs
#
#  if ( $Build ) {
#    if ( ! $SkipGalileo ) {
#      $galileoBuild = Start-Job -Name 'GalileoBuild' -ArgumentList $GalileoRepoLocation -ScriptBlock {
#        param(
#          [string] $repo
#        )
#        cd $repo
#        try {
#          Write-Progress -Id 2 -ParentId 1 -Activity 'Galileo' -Status 'MSBuild'
#          & "$repo\Build.cmd"
#          cd "$repo\Galileo"
#          if ( ! ( Test-Path "$repo\Galileo\yarn.lock" ) ) {
#            Write-Progress -Id 2 -ParentId 1 -Activity 'Galileo' -Status 'Npm'
#            npm install
#          } else {
#            Write-Progress -Id 2 -ParentId 1 -Activity 'Galileo' -Status 'Yarn'
#            yarn install
#          }
#          Write-Progress -Id 2 -ParentId 1 -Activity 'Galileo' -Status 'Grunt'
#          grunt release
#          if ( ! ( Test-Path "$GalileoRepoLocation\Galileo\Scripts\build\vendor.js" ) ) {
#            grunt vendor
#          }
#        } catch {
#          throw
#        }
#        Write-Progress -Id 2 -ParentId 1 -Activity 'Galileo' -Status 'Completed' -Completed
#      }
#    }
#
#    if ( ! $SkipNarya ) {
#      $naryaBuild = Start-Job -Name 'NaryaBuild' -ArgumentList $NaryaRepoLocation -ScriptBlock {
#        param(
#          [string] $repo
#        )
#        cd $repo
#        $pluginDirectory = "$repo\NaryaApi\Plugins"
#        try {
#          New-Item -Type Directory -Path "$pluginDirectory" > $Null 2>&1
#
#          Write-Progress -Id 3 -ParentId 1 -Activity 'Narya' -Status 'Nuget restore'
#          nuget restore "$repo\narya.sln"
#          Write-Progress -Id 3 -ParentId 1 -Activity 'Narya' -Status 'MSBuild'
#          msbuild "$repo\narya.sln"
#
#          cd "$repo\NaryaWebClient\app"
#          if ( ! ( Test-Path "$repo\NaryaWebClient\app\yarn.lock" ) ) {
#            Write-Progress -Id 3 -ParentId 1 -Activity 'Narya' -Status 'Npm'
#            npm install
#          } else {
#            Write-Progress -Id 3 -ParentId 1 -Activity 'Narya' -Status 'Yarn'
#            yarn install
#          }
#          Write-Progress -Id 3 -ParentId 1 -Activity 'Narya' -Status 'Bower'
#          bower install
#
#        } catch {
#          throw
#        }
#        Write-Progress -Id 3 -ParentId 1 -Activity 'Narya' -Status 'Completed' -Completed
#      }
#    }
#
#    while ( ( @( $galileoBuild, $naryaBuild ) | Where-Object { $_.State -Eq 'Running' } ).Count -Gt 0 ) {
#    	Write-Progress -Id 1 -Activity 'Building Projects' -Status 'Building'
#    	foreach ( $job in ( $galileoBuild, $naryaBuild ) ) {
#        if ( $job ) {
#          $progress = $job.ChildJobs[0].Progress | Select-Object -Last 1
#        }
#    		if ( $progress ) {
#    			Write-Progress -ParentId 1 -Id $progress.ActivityId -Activity $progress.Activity -Status $progress.StatusDescription -PercentComplete $progress.PercentComplete
#    		}
#    	}
#      Start-Sleep -Seconds 1
#    }
#
#    Write-Progress -Id 1 -Activity 'Building Projects' -Completed
#    Write-Progress -ParentId 1 -Id 2 -Activity 'Galileo' -Completed
#    Write-Progress -ParentId 1 -Id 3 -Activity 'Narya' -Completed
#
#    $failedJobs = Get-Job | Where-Object { $_.State -Ne 'Completed' }
#    if ( $failedJobs ) {
#      Write-Error 'Build failure: collect data from jobs to see errors'
#      $failedJobs
#      Return 1
#    }
#
#    Write-Progress -Activity 'Building Projects' -Completed
#
#    Stop-ContentDevJobs
#  }
#
#  $galileoIIS = Get-CsprojIISConfig "$GalileoRepoLocation\Galileo\galileo.csproj"
#  $naryaIIS = Get-CsprojIISConfig "$NaryaRepoLocation\NaryaApi\NaryaApi.csproj"
#  $naryaEmber = @{ Url = 'http://localhost:4200'; Port = 4200 }
#
#  try {
#    if ( ! $SkipGalileo ) {
#      $galileo = Start-Job -Name 'Galileo' -ArgumentList $GalileoRepoLocation, $IISExpressBinary, $galileoIIS -ScriptBlock {
#        param(
#          [string] $repo,
#          [string] $iis,
#          [hashtable] $config
#        )
#        & "$iis" /port:"$($config.Port)" /path:"$repo\Galileo"
#      }
#
#      Write-Host "Hosting Galileo at $($galileoIIS.Url)"
#    }
#
#    if ( ! $SkipNarya ) {
#      $naryaApi = Start-Job -Name 'NaryaApi' -ArgumentList $NaryaRepoLocation, $IISExpressBinary, $naryaIIS -ScriptBlock {
#        param(
#          [string] $repo,
#          [string] $iis,
#          [hashtable] $config
#        )
#        & "$iis" /port:"$($config.Port)" /path:"$repo\NaryaApi"
#      }
#
#      $narya = Start-Job -Name 'Narya' -ArgumentList $NaryaRepoLocation, $naryaEmber -ScriptBlock {
#        param(
#          [string] $repo,
#          [hashtable] $config
#        )
#        cd "$repo\NaryaWebClient\app\app"
#        ember serve --port $config.Port
#      }
#
#      Write-Host "Hosting Narya API at $($naryaIIS.Url)"
#      Write-Host "Hosting Narya at $($naryaEmber.Url)"
#    }
#
#    while ( ! ( ( Read-Host 'Enter Q to stop hosting' ) -Eq 'q' ) ) { }
#  }
#  finally {
#    Stop-ContentDevJobs
#  }
#
#}
