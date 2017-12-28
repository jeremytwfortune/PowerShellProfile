function Initialize-LocalContentDev {
  param(
    [switch] $SkipNarya,
    [string] $NaryaRepoLocation = $Env:NARYA_REPO,
    [switch] $SkipGalileo,
    [string] $GalileoRepoLocation = $Env:GALILEO_REPO
  )

  if ( -Not ( Test-Path $NaryaRepoLocation ) -Or -Not ( Test-Path $GalileoRepoLocation ) ) {
    Write-Error 'Both repo locations must be set. Consider passing parameters or setting $Env:NARYA_REPO and $Env:GALILEO_REPO.'
    exit 1
  }

  if ( -Not $SkipNarya ) {
    $naryaConfigOverride = "$Home\Narya.config.json.override"
    if ( Test-Path $naryaConfigOverride ) {
      Write-Verbose "Copying $naryaConfigOverride to Narya repository"
      Copy-Item -Force $naryaConfigOverride $NaryaRepoLocation\NaryaApi\config.json.override
    }
  }

  if ( -Not $SkipGalileo ) {
    [xml] $webConfig = Get-Content "$GalileoRepoLocation\Galileo\web.config"

    #if ( ( $webConfig.configuration.'system.web'.compilation.assemblies.add | Where-Object -Property Assembly -EQ "System.Runtime" ).Count -Eq 0 ) {
    #  [xml] $systemRuntime = '<assemblies><add assembly="System.Runtime, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" /></assemblies>'
    #  $webConfig.configuration.'system.web'.compilation.AppendChild( $webConfig.ImportNode( $systemRuntime.assemblies, $true ) )
    #}

    $webClientUrl = $webConfig.configuration.appSettings.add | Where-Object { $_.key -Eq "WebClientUrl" }
    $webClientUrl.Value = "http://localhost/WebClientTest.Adapter1.WebClient"
    $webConfig.save( "$GalileoRepoLocation\Galileo\web.config" )

    $galileoConnectionStrings = "$Home\Galileo.ConnectionStrings.config"
    if ( ! ( Test-Path $galileoConnectionStrings ) ) {
      Write-Verbose "Copying $galileoConnectionStrings to Galileo repository"
      Copy-Item -Force $galileoConnectionStrings $GalileoRepoLocation\Galileo\ConnectionStrings.config.default
    }
  }
}
