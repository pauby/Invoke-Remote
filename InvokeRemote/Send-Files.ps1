<#
.SYNOPSIS
Send files to a remote hosts

.DESCRIPTION
Wrapper for Copy-Item with remote session

.PARAMETER ComputerName
ip or hostname of remote host

.PARAMETER LocalPath
local path of files

.PARAMETER RemotePath
remote drop path

.PARAMETER Credential
credentials used for login

.PARAMETER Session
remote session to be used (if already present - see Get-RemoteSession.ps1)

.PARAMETER ConnectRetryCount 
Number of retries if connection to remote host cannot be established

.PARAMETER ConnectRetryDelay
Time (in seconds) between re-trying to establish a remote connection

.LINK
https://github.com/mwallner/Invoke-Remote
#>

param(
  [Parameter(Mandatory = $True)]
  [string] $ComputerName,

  [Parameter(Mandatory = $True)]
  [string[]] $LocalPath,

  [Parameter(Mandatory = $True)]
  [string] $RemotePath,

  [Parameter(Mandatory = $False)]
  [PSCredential] $Credential = $null,
	
  [Parameter(Mandatory = $False)]
  $Session,
	
  [Parameter(Mandatory = $False)]
  [int] $ConnectRetryCount = 10,

  [Parameter(Mandatory = $False)]
  [int] $ConnectRetryDelay = 1
)

Import-Module $(Join-Path $PSScriptRoot "ir.common.psm1")
Write-IRInfo 2 " > Send-Files < "

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

  foreach ($f in $LocalPath) {
    Send-FileToRemote -PathOnLocal $f -PathOnRemote $RemotePath -Session $remotesession -Recurse $True
  }
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