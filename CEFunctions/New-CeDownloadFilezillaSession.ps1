function New-CeDownloadFileZillaSession {
  [CmdletBinding()] param (
    [string] $RemotePath,

    [ValidateNotNullOrEmpty()]
    [PSCredential] $Credential = $CredentialStore.Ce
  )
  $fileZillaBin = "C:\Program Files\FileZilla FTP Client\filezilla.exe"
  $connection = "ftp://$($Credential.UserName):$($Credential.GetNetworkCredential().Password)@download.careevolution.com"
  if ( $RemotePath ) {
    $connection = "$connection/$($RemotePath.TrimStart('/'))"
  }
  & $fileZillaBin "$connection" --local "$(Get-Location)"
}
