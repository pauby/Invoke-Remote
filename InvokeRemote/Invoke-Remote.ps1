<#
.SYNOPSIS
Run commands or scripts on remote hosts and get the results

.DESCRIPTION
Invoke-Remote ist just a wrapper for Invoke-Command and other Boxstarter commands.

.PARAMETER ComputerName
ip or hostname of remote host

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
	[Parameter(Mandatory=$True)]
	[string] $ComputerName,

	[Parameter(Mandatory=$False)]
	[string[]] $commands,

	[Parameter(Mandatory=$False)]
	[string[]] $scripts,

	[Parameter(Mandatory=$False)]
	[PSCredential] $Credential = $null,

	[Parameter(Mandatory=$False)]
	[int] $ConnectRetryCount = 10,

	[Parameter(Mandatory=$False)]
	[int] $ConnectRetryDelay = 1
)

Import-Module $(Join-Path $PSScriptRoot "ir.common.psm1")
Write-IRInfo 2 " > Invoke-Remote < "

$connTest = Test-WsMan $ComputerName -ErrorAction SilentlyContinue
if (-Not $connTest) {
	Write-IRInfo 14 "connection to '$ComputerName' could not be established..."
	$retryCount = 1
	While ($($retryCount -lt $ConnectRetryCount) -And $(-Not $connTest)) {
		Write-IRInfo 14 "going to sleep for $ConnectRetryDelay seconds..."
		Start-Sleep -Seconds $ConnectRetryDelay
		Write-IRInfo 14 "retrying connection... [$retryCount/$ConnectRetryCount]"
		$connTest = Test-WsMan $ComputerName -ErrorAction SilentlyContinue
		$retryCount = $retryCount + 1
	}
	if ($retryCount -eq $ConnectRetryCount) {
		Write-IRInfo 12 "connection timeout"
		exit 1
	}
}

# the one and only - all commands will be run in this session
if ($Credential) {
	$remotesession = New-PSSession -computername $ComputerName -Credential $Credential
} else {
	$remotesession = New-PSSession -computername $ComputerName
}
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