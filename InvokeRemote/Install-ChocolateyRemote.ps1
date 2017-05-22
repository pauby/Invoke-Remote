<#
.SYNOPSIS
Install a Chocolatey package on  a remote host

.DESCRIPTION
Uses Boxstarter to install a Chocolatey Package

.PARAMETER ComputerName
ip or hostname of remote host

.PARAMETER PackageName
id of Chocolatey package to install

.PARAMETER Credential
credentials used for login

.PARAMETER ConnectRetryCount 
Number of retries if connection to remote host cannot be established

.PARAMETER ConnectRetryDelay
Time (in seconds) between re-trying to establish a remote connection

.LINK
http://boxstarter.org/
https://chocolatey.org/
#>
param(
	[Parameter(Mandatory=$True)]
	[string] $ComputerName,
	
	[Parameter(Mandatory=$True)]
	[string] $PackageName,
	
	[Parameter(Mandatory=$False)]
	[PSCredential] $Credential = $null,

	[Parameter(Mandatory=$False)]
	[int] $ConnectRetryCount = 10,

	[Parameter(Mandatory=$False)]
	[int] $ConnectRetryDelay = 1
)

Import-Module $(Join-Path $PSScriptRoot "ir.common.psm1")
Write-IRInfo 2 " > Invoke-ChocolateyRemote < "

Wait-ForRemote -ComputerName $ComputerName -ConnectRetryCount $ConnectRetryCount -ConnectRetryDelay $ConnectRetryDelay
Get-BoxstarterEnv

if ($Credential) {
	Install-BoxstarterPackage -ComputerName $ComputerName -PackageName $PackageName -Credential $Credential
} else {
	Install-BoxstarterPackage -ComputerName $ComputerName -PackageName $PackageName
}
