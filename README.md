# Invoke-Remote
[WIP] enhance workflow when dealing with remote Windows environments

## Basics
Invoke-Remote ist just a wrapper for `Invoke-Command` and other [Boxstarter](https://github.com/mwrock/boxstarter) commands.
You'll need [Chocolatey](https://chocolatey.org/) and [Boxstarter](https://github.com/mwrock/boxstarter) all set up to use all of Invoke-Remote's goodness!

## Features
### Command Invoke-Remote
Adds some spice to `Invoke-Command`

The result of `Invoke-Remote` is an object with following structure:
| Member         | Type          | Description                |
| -------------  | ------------  | -------------------------  |
| commands_in    | string[]      | the input commands that were run |
| commands_out   | string[]      | the output of commands_in |
| scripts_in     | string[]      | the path of the scripts that were run |
| scripts_out    | string[]      | the output of the scripts in scripts_in |

### Command Install-ChocolateyRemote
Just a wrapper for `Install-BoxstarterPackage` that ensures you've got Boxstarter fired up.

## Sample Usage
You'll need to import the module first!
```
> Import-Module InvokeRemote\Invoke-Remote.psm1
```

sending two commands to a host called "some_hostname":
```
> Invoke-Remote "some_hostname" "Write-Host Hello World","Write-Host YAY from $(hostname)"
```

for the lazy sysadmins, there is also an 'ir' Alias :-)
```
> ir "some_hostname" "echo 'this is $(hostname)'"
```

## Roadmap
what you see currently is a very, very basic module that just provides some helper functions for remote operations.

I plan on adding:
* own DSL compatible with [psake](https://github.com/psake/psake)
  * tasks, dependencies, tests
* support for parallel tasking
* better error-handling
* reporting + statistics
