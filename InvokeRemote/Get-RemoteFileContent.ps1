<#
.SYNOPSIS
Get the content of a file on a remote host

.DESCRIPTION

.PARAMETER ComputerName
ip or hostname of remote host

.PARAMETER Session
remote session to be used (if already present - see Get-RemoteSession.ps1)

.PARAMETER FolderPath

.PARAMETER FileName

.PARAMETER WaitForFile

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

    [Parameter(Mandatory = $True)]
    [string] $FolderPath,

    [Parameter(Mandatory = $True)]
    [string] $FileName,

    [Parameter(Mandatory = $False)]
    [switch] $WaitForFile,

    [Parameter(Mandatory = $False)]
    [PSCredential] $Credential = $null,

    [Parameter(Mandatory = $False)]
    [int] $ConnectRetryCount = 10,

    [Parameter(Mandatory = $False)]
    [int] $ConnectRetryDelay = 1
)
$ErrorActionPreference = "Stop"
Import-Module $(Join-Path $PSScriptRoot "ir.common.psm1")
Write-IRInfo 2 " > Get-RemoteFileContent < "


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

    $resultobj = @{}
    $resultobj.File = Join-Path $FolderPath $FileName
    $doWaitForFileCreation = if ($WaitForFile) { $True } else { $False }
    Write-IRInfo White "getting content of $($resultobj.File)"
    $scriptblk = {
        param($folder, $file, $doWaitForFile)
        if (-Not $doWaitForFile) {
            Write-Host "A"
            Get-Content $(Join-Path $folder $file)
        }
        else {
            Write-Host "B"
            if (-Not (Test-Path $file)) {
                Write-Host "waiting for file..."
                $fsw = New-Object IO.FileSystemWatcher $folder, $file -Property @{IncludeSubdirectories = $false; NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'} 
                Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action { 
                    #kudos https://gallery.technet.microsoft.com/scriptcenter/Powershell-FileSystemWatche-dfd7084b
                    $name = $Event.SourceEventArgs.Name 
                    $changeType = $Event.SourceEventArgs.ChangeType 
                    $timeStamp = $Event.TimeGenerated 
                    Write-Host "The file '$name' was $changeType at $timeStamp" -fore green
                    $global:RemoteFileCreated = $true								
                } 
										
                while ($global:RemoteFileCreated -eq $false) {
                    Start-Sleep -Milliseconds 100
                }

                Unregister-Event FileCreated 
                Get-Content $(Join-Path $folder $filepath)
            }
        }
    }
        
    $obj = $(Invoke-Command -ScriptBlock $scriptblk -session $remotesession -ArgumentList @($FolderPath, $FileName, $doWaitForFileCreation)) 
    $resultobj.FileContent += $obj
    Enter-Loggable { $obj }
    $resultobj
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
