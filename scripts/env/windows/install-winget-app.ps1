<#
.SYNOPSIS
	Installs an app via winget

.DESCRIPTION
	This PowerShell script installs an app from winget.

.PARAMETER ApplicationId
    The ID of the application to install.

.PARAMETER ApplicationSource
    The source from which to install the application. Default is "winget".

.PARAMETER Upgrade
    Switch to upgrade the application if it is already installed.

.EXAMPLE
	PS> ./install-winget-app.ps1 Docker.DockerDesktop --Source winget --Upgrade

.LINK
	https://github.com/pagnozzi/PowerShell

.NOTES
	Author: Piergiorgio Vagnozzi| License: CC0
#>

#Requires -RunAsAdministrator

Param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$ApplicationId,
    [Parameter(Mandatory=$false)]
    [switch]$Upgrade = $false
)

function AppInstalled([string]$AppId) {    
    $found = winget list | Where-Object { $_ -like "*$AppId*" }
    return $found ? $true : $false
}

function AppUpgradable([string]$AppId) {    
    $update = winget upgrade --id $AppId | Select-Object -First 1
    return $update ? $true : $false                
}

function AppInstall([string]$AppId) {            
    & winget.exe install --id $AppId -e --accept-source-agreements --disable-interactivity --silent --accept-package-agreements --force
    if ($lastExitCode -ne "0") { 
        throw "Error installing ${ApplicationId}: ${$Error[0]}"
    }            
}

function AppUpgrade([string]$AppId) {
    & winget.exe upgrade --id $AppId -e --accept-source-agreements --disable-interactivity --silent --accept-package-agreements
    if ($lastExitCode -ne "0") { 
        throw "Error installing ${ApplicationId}: ${$Error[0]}"
    }
}

[bool]$DoUpgrade = $false
try {
    if (AppInstalled($ApplicationId)) {                
        if (!$Upgrade) {
            "✅ ${ApplicationId} already installed"
            exit 0
        }        

        if (!AppUpgradable($ApplicationId)) {
            "✅ ${ApplicationId} already installed and not update found"
            exit 0
        }

        $DoUpgrade = $true
    }    

    if ($DoUpgrade) {
        "👉 Upgrading ${ApplicationId}, please wait..."
        AppUpgrade($ApplicationId)
        "✅ ${ApplicationId} upgraded successfully."
    }
    else {     
        "👉 Installing ${ApplicationId}, please wait..."
        AppInstall($ApplicationId)
        "✅ ${ApplicationId} installed successfully."
    }

}
catch {
    "⚠️ $_"
    exit 1
}

