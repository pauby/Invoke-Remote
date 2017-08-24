<#
.SYNOPSIS
Run commands or scripts on remote hosts and get the results

.DESCRIPTION
Invoke-Remote ist just a wrapper for Invoke-Command and other Boxstarter commands.

.PARAMETER ComputerName
ip or hostname of remote host

.PARAMETER Session
remote session to be used (if already present - see Get-RemoteSession.ps1)

.PARAMETER commands
commands to run

.PARAMETER scripts
scripts to execute

.PARAMETER Credential
credentials used for login

.PARAMETER ConnectRetryCount 
Number of retries if connection to remote host cannot be established

.PARAMETER ConnectRetryDelay
Time (in seconds) between re-trying to establish a remote connection

.LINK
https://github.com/mwallner/Invoke-Remote
#>

param(
  [Parameter(ParameterSetName = 'NoSession', Mandatory = $True, Position = 0)]
  [string] $ComputerName,
	
  [Parameter(ParameterSetName = 'ExplicitSession', Mandatory = $True, Position = 0)]
  $Session,

  [Parameter(Mandatory = $False)]
  [string[]] $commands,

  [Parameter(Mandatory = $False)]
  [string[]] $scripts,

  [Parameter(Mandatory = $False)]
  [PSCredential] $Credential = $null,

  [Parameter(Mandatory = $False)]
  [int] $ConnectRetryCount = 10,

  [Parameter(Mandatory = $False)]
  [int] $ConnectRetryDelay = 1
)

Import-Module $(Join-Path $PSScriptRoot "ir.common.psm1")
Write-IRInfo 2 " > Invoke-Remote < "

try {
  # the one and only - all commands will be run in this session
  if ($Session) {
    $remotesession = $Session
  }
  else {
    $remotesession = Wait-ForRemoteSession 	-ComputerName $ComputerName `
      -ConnectRetryCount $ConnectRetryCount `
      -ConnectRetryDelay $ConnectRetryDelay
  }

  $resultobj = @{}
  $resultobj.commands_in = $commands
  if ($commands) {
    $resultobj.commands_out = @()
    $commands | ForEach-Object {
      $scriptblk = [scriptblock]::Create($_)
      $obj = $(Invoke-Command -ScriptBlock $scriptblk -session $remotesession )
      $resultobj.commands_out += $obj
      Enter-Loggable { $obj }
    }
  }

  $resultobj.scripts_in = $scripts
  if ($scripts) {
    $resultobj.scripts_out = @()
    $scripts | ForEach-Object {
      $path = $_
      $obj = $(Invoke-Command -FilePath $path -session $remotesession)
      $resultobj.scripts_out += $obj
      Enter-Loggable { $obj }
    }
  }
  $resultobj
}
catch {
  throw $_.Exception
}
finally {
  if (-Not $Session) {
    #only remove newly created session objects!
    Remove-PSSession $remotesession		
  }
}