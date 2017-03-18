<#
.SYNOPSIS
Run pester scripts on remote machines

.DESCRIPTION
Invoke pester scripts on remote hosts (just as if they were local)

.PARAMETER ComputerName
ip or hostname of remote host

.PARAMETER Path
path of pester script

.PARAMETER Tests
pester tests to run

.PARAMETER Credential
credentials used for login

.PARAMETER ConnectRetryCount 
Number of retries if connection to remote host cannot be established

.PARAMETER ConnectRetryDelay
Time (in seconds) between re-trying to establish a remote connection

.LINK
https://github.com/pester/pester
#>

param (
	[Parameter(Mandatory=$True)]
	[string] $ComputerName,
	
	[Parameter(Mandatory=$True)]
	[string] $Path,

	[Parameter(Mandatory=$False)]
	[string[]] $Tests = "Default",

	[Parameter(Mandatory=$False)]
	[pscredential] $Credential,
	
	[Parameter(Mandatory=$False)]
	[int] $ConnectRetryCount = 10,

	[Parameter(Mandatory=$False)]
	[int] $ConnectRetryDelay = 1
)

Import-Module $(Join-Path $PSScriptRoot "ir.common.psm1")
Write-IRInfo 2 " > Invoke-RemotePester < "

try {
	$remotesession = Wait-ForRemoteSession 	-ComputerName $ComputerName `
											-Credential $Credential `
											-ConnectRetryCount $ConnectRetryCount `
											-ConnectRetryDelay $ConnectRetryDelay
   
   if (-Not $(Get-CanLoadPowerShellModule $remotesession 'Pester')) {
	   & $(Join-Path $PSScriptRoot "Install-ChocolateyRemote.ps1") -ComputerName $ComputerName -PackageName 'Pester' -Credential $Credential
   }
   Import-Module -Name 'Pester' -PSSession $Session
   
	$remoteTmpDir = New-RemoteTmpDir -Session $remotesession
	$remotePath= Join-Path $remoteTmpDir $($(Get-Item $Path).Name)

	Send-FileToRemote -Session $remotesession `
										-PathOnLocal "$Path" `
										-PathOnRemote "$remoteTmpDir" `
										-ErrorAction Stop
	
	$result = Invoke-Command 	-ScriptBlock { param($Path, $Tests) `
										$dotnetframework = "4.5.1"; `
										Invoke-Pester -Script $Path -TestName $Tests -PassThru `
									} `
									-ArgumentList $remotePath, $Tests `
									-Session $remoteSession

	Invoke-Command 	-ScriptBlock { param($Path) Remove-Item $Path -Force -Recurse } `
									-ArgumentList $remoteTmpDir `
									-Session $remotesession `
									-ErrorAction Continue

	$result
} catch {
	throw $_.Exception
} finally {
	Remove-PSSession $remotesession
}