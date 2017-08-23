$ErrorActionPreference = 'Stop'; 

$packageName = 'Invoke-Remote'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$IRBase = Join-Path $toolsDir "InvokeRemote"

Push-Location $toolsDir
try {
  Install-ChocolateyPowershellCommand `
    -PackageName "$packageName.ir" `
    -PSFileFullPath $(Join-Path $IRBase "Invoke-Remote.ps1")
  .\Add-Alias.ps1 -visibility alluser -aliasName "Invoke-Remote" -aliasTarget $(Join-Path $IRBase "Invoke-Remote.ps1")

  Install-ChocolateyPowershellCommand `
    -PackageName "$packageName.ir-psake" `
    -PSFileFullPath $(Join-Path $IRBase "Invoke-RemotePsake.ps1")
  .\Add-Alias.ps1 -visibility alluser -aliasName "Invoke-RemotePsake" -aliasTarget $(Join-Path $IRBase "Invoke-RemotePsake.ps1")

  Install-ChocolateyPowershellCommand `
    -PackageName "$packageName.ir-pester" `
    -PSFileFullPath $(Join-Path $IRBase "Invoke-RemotePester.ps1")
  .\Add-Alias.ps1 -visibility alluser -aliasName "Invoke-RemotePester" -aliasTarget $(Join-Path $IRBase "Invoke-RemotePester.ps1")

  Install-ChocolateyPowershellCommand `
    -PackageName "$packageName.ir-choco" `
    -PSFileFullPath $(Join-Path $IRBase "Install-ChocolateyRemote.ps1")
  .\Add-Alias.ps1 -visibility alluser -aliasName "Invoke-ChocolateyRemote" -aliasTarget $(Join-Path $IRBase "Invoke-ChocolateyRemote.ps1")
	
  Install-ChocolateyPowershellCommand `
    -PackageName "$packageName.ir-files" `
    -PSFileFullPath $(Join-Path $IRBase "Send-Files.ps1")
  .\Add-Alias.ps1 -visibility alluser -aliasName "Send-Files" -aliasTarget $(Join-Path $IRBase "Send-Files.ps1")
}
finally {
  Pop-Location
}
