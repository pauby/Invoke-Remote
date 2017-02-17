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

.LINK
https://github.com/mwallner/Invoke-Remote
#>
param(
	[Parameter(Mandatory=$True)]
	[string] $ComputerName,
	
	[Parameter(Mandatory=$True)]
	[string] $PackageName,
	
	[Parameter(Mandatory=$False)]
	[PSCredential] $Credential = $null
)

function Get-BoxstarterEnv {
  Import-Module Boxstarter.Bootstrapper -Force -Verbose
  Import-Module Boxstarter.Chocolatey -Force -Verbose
  Import-Module Boxstarter.Common -Force -Verbose
  Import-Module Boxstarter.HyperV -Force -Verbose
  Import-Module Boxstarter.WinConfig -Force -Verbose
}


Get-BoxstarterEnv
if ($Credential) {
	Install-BoxstarterPackage -ComputerName $ComputerName -PackageName $PackageName -credentials $Credential
} else {
	Install-BoxstarterPackage -ComputerName $ComputerName -PackageName $PackageName
}
