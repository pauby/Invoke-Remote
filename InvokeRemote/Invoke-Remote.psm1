<# 

Invoke-Remote requires 'Powershell Remoting' to be enabled to target hosts.
> use 'Enable-PSRemoting -Force' on any host you want to connect to

#>
$ErrorActionPreference = 'Stop' # better be safe than sorry!


function Invoke-Remote {
  param(
    # ip or hostname of remote host
    [Parameter(Mandatory=$True)]
    [string] $ComputerName,
    # commands to run
    [Parameter(Mandatory=$False)]
    [string[]] $commands,
    # scripts to execute
    [Parameter(Mandatory=$False)]
    [string[]] $scripts,
    # credentials used for login
    [Parameter(Mandatory=$False)]
    [SecureString] $credential = $null
  )
  
  # check if remote connection are possible to the correspeding host
  Test-WsMan $ComputerName

  # the one and only - all commands will be run in this session
  $remotesession = New-PSSession -computername $ComputerName
  $resultobj = @{}
  $resultobj.commands_in = $commands
  if ($commands) {
    $resultobj.commands_out = @()
    $commands | ForEach-Object {
      $scriptblk = [scriptblock]::Create($_)
      $resultobj.commands_out += $(Invoke-Command -ScriptBlock $scriptblk -session $remotesession )
    }
  }
  
  $resultobj.scripts_in = $scripts
  if ($scripts) {
    $resultobj.scripts_out = @()
    $scripts | ForEach-Object {
      $path = $_
      $resultobj.scripts_out += $(Invoke-Command -FilePath $path -session $remotesession)
    }
  }
  Remove-PSSession $remotesession
  $resultobj
}
Set-Alias -name ir -Value Invoke-Remote


function Get-BoxstarterEnv {
  Import-Module Boxstarter.Bootstrapper -Force -Verbose
  Import-Module Boxstarter.Chocolatey -Force -Verbose
  Import-Module Boxstarter.Common -Force -Verbose
  Import-Module Boxstarter.HyperV -Force -Verbose
  Import-Module Boxstarter.WinConfig -Force -Verbose
}


function Install-ChocolateyRemote {
   param(
    # ip or hostname of remote host
    [Parameter(Mandatory=$True)]
    [string] $ComputerName,
    # chocolatey package to install
    [Parameter(Mandatory=$True)]
    [string] $PackageName,
    # credentials used for login
    [Parameter(Mandatory=$False)]
    [SecureString] $credential = $null
  )
  Get-BoxstarterEnv
  if ($credentials) {
    Install-BoxstarterPackage -ComputerName $ComputerName -PackageName $PackageName -credentials $credential
  } else {
    Install-BoxstarterPackage -ComputerName $ComputerName -PackageName $PackageName
  }
} 


Export-ModuleMember Invoke-Remote
Export-ModuleMember Install-ChocolateyRemote
Export-ModuleMember -Alias ir
