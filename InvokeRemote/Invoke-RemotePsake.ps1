<#
.SYNOPSIS
Run psake scripts on remote machines

.DESCRIPTION
Invoke psake scripts on remote hosts (just as if they were local)

.PARAMETER ComputerName
ip or hostname of remote host

.PARAMETER Session
remote session to be used (if already present - see Get-RemoteSession.ps1)

.PARAMETER Path
path of psake script

.PARAMETER Tasks
psake tasts to run

.PARAMETER Credential
credentials used for login

.PARAMETER ConnectRetryCount 
Number of retries if connection to remote host cannot be established

.PARAMETER ConnectRetryDelay
Time (in seconds) between re-trying to establish a remote connection

.LINK
https://github.com/psake/psake
#>

param (
  [Parameter(ParameterSetName = 'NoSession', Mandatory = $True, Position = 0)]
  [string] $ComputerName,
	
  [Parameter(ParameterSetName = 'ExplicitSession', Mandatory = $True, Position = 0)]
  $Session,

  [Parameter(Mandatory = $True)]
  [string] $Path,

  [Parameter(Mandatory = $False)]
  [string[]] $Tasks = "Default",

  [Parameter(Mandatory = $False)]
  [pscredential] $Credential,

  [Parameter(Mandatory = $False)]
  [int] $ConnectRetryCount = 10,

  [Parameter(Mandatory = $False)]
  [int] $ConnectRetryDelay = 1
)
$ErrorActionPreference = "Stop"
Import-Module $(Join-Path $PSScriptRoot "ir.common.psm1")
Write-IRInfo 2 " > Invoke-RemotePsake < "

try {
  # the one and only - all commands will be run in this session
  if ($Session) {
    $remotesession = $Session
  }
  else {
    $remotesession = Wait-ForRemoteSession 	-ComputerName $ComputerName `
      -Credential $Credential `
      -ConnectRetryCount $ConnectRetryCount `
      -ConnectRetryDelay $ConnectRetryDelay
  }

  $remoteTmpDir = New-RemoteTmpDir -Session $remotesession
  $remotePath = Join-Path $remoteTmpDir $($(Get-Item $Path).Name)
	
  Enter-Loggable {
		
    Send-FileToRemote -Session $remotesession `
      -PathOnLocal "$Path" `
      -PathOnRemote "$remoteTmpDir"`
      -ErrorAction Stop

    $resultobj = Invoke-Command 	-ScriptBlock { param($Path, $Tasks) `
        $dotnetframework = "4.5.1"; `
        if (-Not $(Get-Command "psake" -ErrorAction SilentlyContinue)) {
        `
          . "C:\ProgramData\chocolatey\lib\psake\tools\psake.ps1" -BuildFile $Path -TaskList @Tasks -framework $dotnetframework `
											
      }
      else {
        `
          & { psake -BuildFile $Path -TaskList @Tasks -framework $dotnetframework } `
											
      } `
    } `
      -ArgumentList $remotePath, $Tasks `
      -Session $remoteSession

    Invoke-Command 	-ScriptBlock { param($Path) Remove-Item $Path -Force -Recurse } `
      -ArgumentList $remoteTmpDir `
      -Session $remotesession `
      -ErrorAction Continue

    $resultobj
  }
}
catch {
  Write-IRInfo Red $_.Exception
  $resultobj.Exception += $_.Exception
  $resultobj
  exit 1
}
finally {
  if (-Not $Session) {
    #only remove newly created session objects!
    Remove-PSSession $remotesession		
  }
}