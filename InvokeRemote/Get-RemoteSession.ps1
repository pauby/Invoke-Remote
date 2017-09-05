<#
.SYNOPSIS
connect to a remote computer 

.DESCRIPTION
returns a new PSSession

.PARAMETER ComputerName
ip or hostname of remote host

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
  [Parameter(Mandatory = $True)]
  [string] $ComputerName,

  [Parameter(Mandatory = $False)]
  [PSCredential] $Credential = $null,

  [Parameter(Mandatory = $False)]
  [int] $ConnectRetryCount = 10,

  [Parameter(Mandatory = $False)]
  [int] $ConnectRetryDelay = 1
)
$ErrorActionPreference = "Stop"
Import-Module $(Join-Path $PSScriptRoot "ir.common.psm1")
Write-IRInfo 2 " > Get-RemoteSession < "

return Wait-ForRemoteSession -ComputerName $ComputerName -Credential $Credential -ConnectRetryCount $ConnectRetryCount -ConnectRetryDelay $ConnectRetryDelay