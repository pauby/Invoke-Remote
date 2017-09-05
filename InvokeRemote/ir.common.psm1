

filter HighResTimestamp {"[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] : $_"}

<#
	Write something to stdout pipe (including timestamp)
#>
function Write-IRInfo {
  param (
    [Parameter(Mandatory = $True)]
    [ConsoleColor]$Color,

    [Parameter(Mandatory = $True)]
    [string]$Text 
  )

  $oldColor = $Host.UI.RawUI.ForegroundColor
  try {
    $Host.UI.RawUI.ForegroundColor = $Color
    "(IR) $Text" | HighResTimestamp | Write-Host
  }
  finally {
    $Host.UI.RawUI.ForegroundColor = $oldColor
  }
}


<#
	Wait until a remote host is available (or throw)
#>
function Wait-ForRemote {
  param (
    [Parameter(Mandatory = $True)]
    [string] $ComputerName,

    [Parameter(Mandatory = $False)]
    [int] $ConnectRetryCount = 10,

    [Parameter(Mandatory = $False)]
    [int] $ConnectRetryDelay = 1
  )

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
      throw "failed to wait connect to '$ComputerName'"
    }
  }
} 


<#
	Wait until a remote host is available and open a PSSession
#>
function Wait-ForRemoteSession {
  param (
    [Parameter(Mandatory = $True)]
    [string] $ComputerName,

    [Parameter(Mandatory = $False)]
    [pscredential] $Credential,
		
    [Parameter(Mandatory = $False)]
    [int] $ConnectRetryCount = 10,

    [Parameter(Mandatory = $False)]
    [int] $ConnectRetryDelay = 1
  )

  Wait-ForRemote -ComputerName $ComputerName -ConnectRetryCount $ConnectRetryCount -ConnectRetryDelay $ConnectRetryDelay
  if ($Credential) {
    $remotesession = New-PSSession -EnableNetworkAccess -computername $ComputerName -Credential $Credential 
  }
  else {
    $remotesession = New-PSSession -EnableNetworkAccess -computername $ComputerName
  }
  Write-IRInfo 2 "connected to '$ComputerName'"
  $remotesession
}


<#
	Creates a new temporary directory on remote host (and returns the path)
#>
function New-RemoteTmpDir {
  param (
    [Parameter(Mandatory = $True)]
    [System.Management.Automation.Runspaces.PSSession] $Session
  )

  try {
    Write-IRInfo 13 "determining path of new temp directory..."
    $_get_tmpdir = {
      $parent = [System.IO.Path]::GetTempPath()
      [string] $name = [System.Guid]::NewGuid()
      Join-Path $parent $name
    }
    $tmpDir = Invoke-Command -ScriptBlock $_get_tmpdir -Session $Session
    Write-IRInfo 13 "creating temp directory '$tmpDir'"
    $scriptblk = { param($Path) $(New-Item -Path $Path -ItemType Directory).FullName }
    Invoke-Command -ScriptBlock $scriptblk -ArgumentList $tmpDir -Session $Session
  }
  catch {
    throw $_.Exception
  }
}


<#
	Copy a file from host A to host B
#>
function Send-FileToRemote {
  param (
    [Parameter(Mandatory = $True)]
    [System.Management.Automation.Runspaces.PSSession] $Session,

    [Parameter(Mandatory = $True)]
    [string] $PathOnLocal,
		
    [Parameter(Mandatory = $True)]
    [string] $PathOnRemote,
		
    [Parameter(Mandatory = $False)]
    [bool] $Recurse = $false
  )

  Write-IRInfo 13 "sending file '$PathOnLocal' to '$PathOnRemote' on remote"
  try {
    if ($Recurse) {
      $res = Copy-Item -Path $PathOnLocal -Destination $PathOnRemote -ToSession $Session -Verbose -Recurse
    }
    else {
      $res = Copy-Item -Path $PathOnLocal -Destination $PathOnRemote -ToSession $Session -Verbose
    }
    Enter-Loggable { $res }
  }
  catch {
    throw $_.Exception
  }
}


<#
	Import all Boxstarter goodness
#>
function Get-BoxstarterEnv {
  Import-Module Boxstarter.Bootstrapper -Force
  Import-Module Boxstarter.Chocolatey -Force
  Import-Module Boxstarter.Common -Force
  Import-Module Boxstarter.HyperV -Force
  Import-Module Boxstarter.WinConfig -Force
}


<#
	Checks if a certain PowerShell module is available at 
#>
function Get-CanLoadPowerShellModule {
  param (
    [Parameter(Mandatory = $True)]
    [System.Management.Automation.Runspaces.PSSession] $Session,

    [Parameter(Mandatory = $True)]
    [string] $ModuleName
  )
	
  Write-IRInfo 13 "checkig if PowerShell module '$ModuleName' is available..."
  $moduleAvailable = Get-Module -ListAvailable -Name $ModuleName -PSSession $Session
  if (-Not $moduleAvailable) {
    Write-IRInfo 14 "module NOT available!"
  }
  $moduleAvailable
}


function Out-IRLog {
  param(
    [Parameter(position = 0, ValueFromPipeline = $True)]
    [object]$object
  )
  process {
    Write-Host $object
  }
}


function Enter-Loggable {
  param([ScriptBlock] $script)
  & ($script) 2>&1 | Out-IRLog
}


function Test-Environment {
  Write-IRInfo 13 "status of WinRM: $((Get-Service -Name winrm ).Status)"
}
