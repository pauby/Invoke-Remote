<# 

Invoke-Remote requires 'Powershell Remoting' to be enabled to target hosts.
> use 'Enable-PSRemoting -Force' on any host you want to connect to

#>
$ErrorActionPreference = 'Stop' # better be safe than sorry!
$irScriptPath = (Join-Path $PSScriptRoot "InvokeRemote")

Set-Alias -Name Invoke-Remote -Value (Join-Path $irScriptPath Invoke-Remote.ps1)
Set-Alias -name ir -Value Invoke-Remote
Set-Alias -Name Install-ChocolateyRemote -Value (Join-Path $irScriptPath Install-ChocolateyRemote.ps1)

Export-ModuleMember -Alias Invoke-Remote, ir, Install-ChocolateyRemote
