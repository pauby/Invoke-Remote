

filter HighResTimestamp {"[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff")] : $_"}


function Write-IRInfo {
	param (
		[Parameter(Mandatory=$True)]
		[ConsoleColor]$Color,

		[Parameter(Mandatory=$True)]
		[string]$Text 
	)

	$oldColor = $Host.UI.RawUI.ForegroundColor
	try {
		$Host.UI.RawUI.ForegroundColor = $Color
		"IR] $Text" | HighResTimestamp
	}
	finally {
		$Host.UI.RawUI.ForegroundColor = $oldColor
	}
}

