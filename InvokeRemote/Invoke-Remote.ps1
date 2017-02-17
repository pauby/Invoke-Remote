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
	[PSCredential] $Credential = $null
)

# check if remote connection are possible to the correspeding host
Test-WsMan $ComputerName

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