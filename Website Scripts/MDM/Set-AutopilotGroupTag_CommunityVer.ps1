<#
.SYNOPSIS
    Installs Get-WindowsAutopilotInfoCommunity.ps1 and calls it using the parameter
.DESCRIPTION
    Used alongside a task sequence within Configuration Manager, this script was uses to add the device to autopilot and set a GroupTa
.AUTHOR
    Jonathan Fallis - www.deploymentshare.com
    Nick Benton - www.oddsandendpoints.co.uk
.VERSION
    1.0.7 - Changed WinRM configuration
    1.0.6 - Added Microsoft.Graph.Authentication to the required modules and requirement for WinRM
    1.0.5 - Changed error handling to display in console and use transcript
    1.0.4 - Improved logic
    1.0.3 - Updated so the error handling works
    1.0.2 - Updated to support Get-WindowsAutopilotInfoCommunity and empty groupTags
    1.0.1 - Added Error Logging
    1.0.0 - Original
.EXAMPLE
    .\Set-AutopilotGroupTag -tenantId "123456" -appId "234567" -appSecret "345678" -groupTag "AutopilotDevice"
#>

Param(
    [Parameter(Mandatory = $true)]
    [string]$tenantId,
    [Parameter(Mandatory = $true)]
    [string]$appId,
    [Parameter(Mandatory = $true)]
    [string]$appSecret,
    [Parameter(Mandatory = $false)]
    [string]$groupTag
)

$ErrorActionPreference = 'stop'
$workingDir = "$env:SystemDrive\Windows\Temp"
$PowerShellDir = "$env:ProgramFiles\WindowsPowerShell\Modules"
$logFile = "$workingDir\Set-AutopilotGroupTag.log"

try {
    Stop-Transcript | Out-Null
}
catch [System.InvalidOperationException]
{}

Start-Transcript -Path $logFile -Append

[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA', "$env:SystemDrive\Windows\system32\config\systemprofile\AppData\Local")

#Test for internet connectivity using 8.8.8.8
If (Test-Connection 8.8.8.8 -Quiet) {
    Write-Output 'Internet Connection OK'
}
Else {
    Write-Error 'Internet Connection check failed'
    Stop-Transcript
    Exit 1
}

#Enable TLS 1.2
Try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Output 'Setting TLS1.2'

}
Catch {
    Write-Error "Setting TLS1.2 - $($_.Exception | Out-String)"
    Stop-Transcript
    Exit 1
}

#Modules
$PowerShellModules = @('PackageManagement', 'PowerShellGet', 'Microsoft.Graph.Authentication')
foreach ($PowerShellModule in $PowerShellModules) {
    $PowerShellModuleVer = Switch ($PowerShellModule) {
        PackageManagement { '1.4.8.1' }
        PowerShellGet { '2.2.5' }
        Microsoft.Graph.Authentication { '2.9.1' }

    }

    $PowerShellModuleURL = Switch ($PowerShellModule) {
        PackageManagement { "https://psg-prod-eastus.azureedge.net/packages/$($PowerShellModule.ToLower()).$PowerShellModuleVer.nupkg" }
        PowerShellGet { "https://psg-prod-eastus.azureedge.net/packages/$($PowerShellModule.ToLower()).$PowerShellModuleVer.nupkg" }
        Microsoft.Graph.Authentication { "https://psg-prod-eastus.azureedge.net/packages/$($PowerShellModule.ToLower()).$PowerShellModuleVer.nupkg" }
    }

    Try {
        if (!(Get-Module -Name $PowerShellModule)) {

            $PowerShellModuleZip = "$workingDir\$PowerShellModule.$PowerShellModuleVer.zip"
            $PowerShellModulePath = "$workingDir\$PowerShellModule\$PowerShellModuleVer"
            $PowerShellModulePF = "$PowerShellDir\$PowerShellModule\$PowerShellModuleVer"

            Write-Output "URL set to $PowerShellModuleURL"
            Invoke-WebRequest -UseBasicParsing -Uri $PowerShellModuleURL -OutFile $PowerShellModuleZip
            Write-Output "Downloaded PowerShellModule $PowerShellModule"
            $Null = New-Item -Path "$PowerShellModulePath" -ItemType Directory -Force
            Expand-Archive -Path $PowerShellModuleZip -DestinationPath "$PowerShellModulePath" -Force
            Write-Output "Unzipped $PowerShellModule"

            if (!(Test-Path -Path "$PowerShellDir\$PowerShellModule" -PathType Container)) {
                $Null = New-Item -Path "$PowerShellDir\$PowerShellModule" -ItemType Directory
            }

            if (Test-Path -Path $PowerShellModulePF -PathType Container) {
                Remove-Item -Path $PowerShellModulePF -Force -Recurse
                Write-Output "Removed existing $PowerShellModulePF"
            }

            Move-Item -Path "$PowerShellModulePath" -Destination $PowerShellModulePF -Force
            Write-Output "Moved $PowerShellModule to $PowerShellModulePF"
        }

        Try {
            Import-Module $PowerShellModule
            Write-Output "$PowerShellModule Module Imported OK"
        }
        Catch {
            Write-Error "$PowerShellModule Import - $($_.Exception | Out-String)"
            Stop-Transcript
            Exit 1
        }

    }
    Catch {
        Write-Error "$PowerShellModule Module - $($_.Exception | Out-String)"
        Stop-Transcript
        Exit 1
    }
}

#enable WinRM
Try {
    Set-WSManQuickConfig -Force -SkipNetworkProfileCheck
    Write-Output 'Enabled WinRM'
}
catch {
    Write-Error "WinRM - $($_.Exception | Out-String)"
    Stop-Transcript
    Exit 1
}

#Install the script
Try {
    Install-Script Get-WindowsAutopilotInfoCommunity -Force
    Write-Output 'Get-WindowsAutopilotInfoCommunity Installed OK'
    Try {
        if (!$groupTag) {
            $groupTag = ''
        }
        Get-WindowsAutopilotInfoCommunity -Online -tenantId $tenantId -appId $appId -appSecret $appSecret -groupTag $groupTag
        Write-Output 'Get-WindowsAutopilotInfoCommunity executed successfully'
        Stop-Transcript
        exit 0
    }
    Catch {
        Write-Error "Get-WindowsAutopilotInfoCommunity execution - $($_.Exception | Out-String)"
        Stop-Transcript
        Exit 1
    }
}
Catch {
    Write-Error "Get-WindowsAutopilotInfoCommunity Install - $($_.Exception | Out-String)"
    Stop-Transcript
    Exit 1
}