# Invoke-Remote
[WIP] enhance workflow when dealing with remote Windows environments

[![Build status](https://ci.appveyor.com/api/projects/status/3kvtb6hgmqakdhw4?svg=true)](https://ci.appveyor.com/project/ManfredWallner/invoke-remote)

## Basics
Invoke-Remote is basically a wrapper for `Invoke-Command` and other [Boxstarter](https://github.com/mwrock/boxstarter) commands in addition to some useful mini-cmdlets that are useful for dealing with remote machines.
You'll need [Chocolatey](https://chocolatey.org/) and [Boxstarter](https://github.com/mwrock/boxstarter) all set up to use all of Invoke-Remote's goodness!
On the machine you are going to control, ensure to have PowerShell remoting enabled. (`Enable-PSRemoting -Force`)

If you are really lazy, you can use my boxstarter 'mini-config' script to setup your PC to allow PowerShell remoting:
* [https://github.com/mwallner/SoftwareAutomation/blob/master/Invoke-Remote/minimal.ps1](https://github.com/mwallner/SoftwareAutomation/blob/master/Invoke-Remote/minimal.ps1)


## Features
There are a couple of parameters that are valid for all commands/scripts:
* `ComputerName` - hostname or IP of remote machine
* `Session` - use this session (forget about `ComputerName` or `Credential`) 
* `Credential` - use this credential for login
* `ConnectRetryCount` - number of times to try a reconnect iff the connection fails
* `ConnectRetryDelay` - delay in seconds between retry attempts

### Command Invoke-Remote
Adds some spice to `Invoke-Command`

The result of `Invoke-Remote` is an object with following structure:

| Member         | Type          | Description                |
| -------------  | ------------  | -------------------------  |
| commands_in    | object[]      | the input commands that were run |
| commands_out   | object[]      | the output of commands_in |
| scripts_in     | object[]      | the path of the scripts that were run |
| scripts_out    | object[]      | the output of the scripts in scripts_in |

### Command Install-ChocolateyRemote
Just a wrapper for `Install-BoxstarterPackage` that ensures you've got Boxstarter fired up.

### Command Invoke-RemotePsake
Transfer and execute psake scripts.
* scripts will be put in temporary folder on remote host

### Command Send-Files
Transfer files to a remote host (recursive, folders also supported)

### Get-RemoteSession
Open a PSSession that may be used for further remote calls (featuring retry count and delay) .

## Sample Usage
You'll need to import the module first!
```
> Import-Module .\Invoke-Remote.psm1
```

sending two commands to a host called "some_hostname":
```
> Invoke-Remote "some_hostname" "Write-Host Hello World","Write-Host YAY from $(hostname)"
```

for the lazy sysadmins, there is also an 'ir' Alias :-)
```
> ir "some_hostname" "echo 'this is $(hostname)'"
```

sending files or folders to a remote host is really easy:
```
> Send-Files "some_hostname" ".\foo" "C:\foo" -Credential $(Get-Credential)
```

run a psake script on a host called "some_hostname":
```
> ir-psake "some_hostname" .\my_psake_script.ps1
```

run two tasks from a psake script on a host called "some_hostname":
```
> ir-psake "some_hostname" .\my_psake_script.ps1 -Tasks "Foo","Bar"
```

## Roadmap
what you see currently is a very, very basic module that just provides some helper functions for remote operations.

