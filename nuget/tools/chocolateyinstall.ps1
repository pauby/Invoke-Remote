$ErrorActionPreference = 'Stop'; 

$packageName= 'Invoke-Remote'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$IRBase = Join-Path $toolsDir "InvokeRemote"

Install-ChocolateyPowershellCommand `
          -PackageName "$packageName.ir" `
          -PSFileFullPath $(Join-Path $IRBase "Invoke-Remote.ps1")

Install-ChocolateyPowershellCommand `
          -PackageName "$packageName.ir-psake" `
          -PSFileFullPath $(Join-Path $IRBase "Invoke-RemotePsake.ps1")
          
Install-ChocolateyPowershellCommand `
          -PackageName "$packageName.ir-pester" `
          -PSFileFullPath $(Join-Path $IRBase "Invoke-RemotePester.ps1")
          
Install-ChocolateyPowershellCommand `
          -PackageName "$packageName.ir-choco" `
          -PSFileFullPath $(Join-Path $IRBase "Install-ChocolateyRemote.ps1")
