<#
.SYNOPSIS
Get the content of a file on a remote host

.DESCRIPTION
Get-RemoteFileContent provides and easy and efficient way for getting the content of remote files.
(with the ability to wait for a file to be created)

.PARAMETER ComputerName
ip or hostname of remote host

.PARAMETER Session
remote session to be used (if already present - see Get-RemoteSession.ps1)

.PARAMETER FolderPath
parent (folder) of file on remote host

.PARAMETER FileName
filename of file on remote host

.PARAMETER WaitForFile
this parameter adds the magic to wait for the file to be created (iff not existent in the first place)

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
    Write-IRInfo White "getting content of $($resultobj.File)"
		
    if (-Not $WaitForFile) {
        $obj = $(Invoke-Command -ScriptBlock { Get-Content $(Join-Path $folder $file) } -session $remotesession -ArgumentList @($FolderPath, $FileName)) 
    }
    else {
				# kudos https://gallery.technet.microsoft.com/scriptcenter/Powershell-FileSystemWatche-dfd7084b
        $remoteScriptText = @"
param(`$folder, `$file)
`$fullpath = Join-Path `$folder `$file
if (-Not (Test-Path `$fullpath)) {
	`$env:RF_FILE_CREATED_INDICATOR = `$false
	`$fsw = New-Object IO.FileSystemWatcher `$folder, `$file -Property @{IncludeSubdirectories = `$false; NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'};
	`$j = Register-ObjectEvent `$fsw Created -SourceIdentifier FileCreated -Action { 
		`$name = `$Event.SourceEventArgs.Name;
		`$changeType = `$Event.SourceEventArgs.ChangeType;
		`$timeStamp = `$Event.TimeGenerated ;
		`$env:RF_FILE_CREATED_INDICATOR = `$true
	}; 
	while (`$env:RF_FILE_CREATED_INDICATOR -eq `$false) { 
		Start-Sleep -Milliseconds 1000;
	};
	`$j = `$fsw.Dispose();
	`$j = Unregister-Event FileCreated
}
Get-Content `$fullpath
"@

        $obj = $(Invoke-Command -ScriptBlock {
                param($scriptText, $folder, $file)
								
                $tmpDir = [System.IO.Path]::GetTempPath()
                [string] $helperScriptName = [System.Guid]::NewGuid()
                $helperScriptPath = Join-Path $tmpDir "$helperScriptName.ps1"

                $scriptText | Out-File $helperScriptPath
                $res = Invoke-Expression "$helperScriptPath '$folder' '$file'"
                Remove-Item $helperScriptPath
                $res
            } -session $remotesession -ArgumentList @($remoteScriptText, $FolderPath, $FileName)) 
    }

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
