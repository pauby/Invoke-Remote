<# 

Invoke-Remote requires 'Powershell Remoting' to be enabled to target hosts.
> use 'Enable-PSRemoting -Force' on any host you want to connect to

#>
$ErrorActionPreference = 'Stop' # better be safe than sorry!
$irScriptPath = (Join-Path $PSScriptRoot "InvokeRemote")

Set-Alias -Name Get-RemoteSession -Value (Join-Path $irScriptPath Get-RemoteSession.ps1)
Set-Alias -name ir-session -Value Get-RemoteSession
Export-ModuleMember -Alias Get-RemoteSession, ir-session

Set-Alias -Name Invoke-Remote -Value (Join-Path $irScriptPath Invoke-Remote.ps1)
Set-Alias -name ir -Value Invoke-Remote
Export-ModuleMember -Alias Invoke-Remote, ir

Set-Alias -Name Install-ChocolateyRemote -Value (Join-Path $irScriptPath Install-ChocolateyRemote.ps1)
Set-Alias -name ir-choco -Value Install-ChocolateyRemote
Export-ModuleMember -Alias Install-ChocolateyRemote, ir-choco

Set-Alias -Name Invoke-RemotePsake -Value (Join-Path $irScriptPath Invoke-RemotePsake.ps1)
Set-Alias -name ir-psake -Value Invoke-RemotePsake
Export-ModuleMember -Alias Invoke-RemotePsake, ir-psake

Set-Alias -Name Send-Files -Value (Join-Path $irScriptPath Send-Files.ps1)
Set-Alias -name ir-files -Value Send-Files
Export-ModuleMember -Alias Send-Files, ir-files

Set-Alias -Name Get-RemoteFileContent -Value (Join-Path $irScriptPath Get-RemoteFileContent.ps1)
Set-Alias -name ir-get -Value Get-RemoteFileContent
Export-ModuleMember -Alias Get-RemoteFileContent, ir-get
