<#PSScriptInfo

.VERSION 1.2.6
.AUTHOR
Jonathan Fallis - www.deploymentshare.com
Nick Benton - www.oddsandendpoints.co.uk

.RELEASENOTES
1.0.0 - Original
1.0.1 - Added Error Logging
1.0.2 - Updated to support Get-WindowsAutopilotInfoCommunity and empty groupTags
1.1.0 - Updated so the error handling works
1.2.0 - Improved logic
1.2.1 - Changed error handling to display in console and use transcript
1.2.2 - Added Microsoft.Graph.Authentication to the required modules and requirement for WinRM
1.2.3 - Changed WinRM configuration
1.2.4 - Updated logging settings
1.2.5 - Included diagnostics script to allow for troubleshooting
1.2.6 - Corrected params to match blog post images

PRIVATEDATA
#>

<#
.SYNOPSIS
    Installs Get-WindowsAutopilotInfoCommunity.ps1 and calls it using the parameters
.DESCRIPTION
    Used alongside a task sequence within Configuration Manager, this script was uses to add the device to autopilot and set a GroupTag

.EXAMPLE
    .\Set-AutopilotGroupTag -TenantID "123456" -AppID "234567" -SecretID "345678" -groupTag "AutopilotDevice"

.NOTES
Should use Task Sequence Variables for the parameters, e.g. %TenantID%, %AppID%, %SecretID%, %GroupTag%

To allow data to be passed to SMSTSLog create a variable called 'OSDLogPowerShellParameters' and set it to 'True'

#>

param(

    [Parameter(Mandatory = $true)]
    [string]$TenantID,

    [Parameter(Mandatory = $true)]
    [string]$AppId,

    [Parameter(Mandatory = $true)]
    [string]$SecretID,

    [Parameter(Mandatory = $false)]
    [string]$GroupTag

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

#region connection check
if (Test-Connection 8.8.8.8 -Quiet) {
    Write-Output 'Internet Connection OK'
}
else {
    Write-Error 'Internet Connection check failed'
    Stop-Transcript
    exit 1
}
#endregion connection check


#region TLS1.2
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Output 'Setting TLS1.2'

}
catch {
    Write-Error "Setting TLS1.2 - $($_.Exception | Out-String)"
    Stop-Transcript
    exit 1
}
#endregion TLS1.2

#region Modules
$PowerShellModules = @('PackageManagement', 'PowerShellGet', 'Microsoft.Graph.Authentication')
foreach ($PowerShellModule in $PowerShellModules) {
    $PowerShellModuleVer = switch ($PowerShellModule) {
        PackageManagement { '1.4.8.1' }
        PowerShellGet { '2.2.5' }
        Microsoft.Graph.Authentication { '2.9.1' }

    }

    $PowerShellModuleURL = switch ($PowerShellModule) {
        PackageManagement { "https://psg-prod-eastus.azureedge.net/packages/$($PowerShellModule.ToLower()).$PowerShellModuleVer.nupkg" }
        PowerShellGet { "https://psg-prod-eastus.azureedge.net/packages/$($PowerShellModule.ToLower()).$PowerShellModuleVer.nupkg" }
        Microsoft.Graph.Authentication { "https://psg-prod-eastus.azureedge.net/packages/$($PowerShellModule.ToLower()).$PowerShellModuleVer.nupkg" }
    }

    try {
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

        try {
            Import-Module $PowerShellModule
            Write-Output "$PowerShellModule Module Imported OK"
        }
        catch {
            Write-Error "$PowerShellModule Import - $($_.Exception | Out-String)"
            Stop-Transcript
            exit 1
        }

    }
    catch {
        Write-Error "$PowerShellModule Module - $($_.Exception | Out-String)"
        Stop-Transcript
        exit 1
    }
}
#endregion Modules

#region WinRM
try {
    Set-WSManQuickConfig -Force -SkipNetworkProfileCheck
    Write-Output 'Enabled WinRM'
}
catch {
    Write-Error "WinRM - $($_.Exception | Out-String)"
    Stop-Transcript
    exit 1
}
#endregion WinRM

#region Windows Autopilot Info Community
try {
    Install-Script Get-WindowsAutopilotInfoCommunity -Force
    Write-Output 'Get-WindowsAutopilotInfoCommunity Installed OK'
    try {
        if (!$groupTag) {
            $groupTag = ''
        }
        Get-WindowsAutopilotInfoCommunity -Online -tenantId $tenantId -appId $appId -appSecret $appSecret -groupTag $groupTag
        Write-Output 'Get-WindowsAutopilotInfoCommunity executed successfully'
    }
    catch {
        Write-Error "Get-WindowsAutopilotInfoCommunity execution - $($_.Exception | Out-String)"
        Stop-Transcript
        exit 1
    }
}
catch {
    Write-Error "Get-WindowsAutopilotInfoCommunity Install - $($_.Exception | Out-String)"
    Stop-Transcript
    exit 1
}
#endregion Windows Autopilot Info Community

#region Windows Diagnostics Community
try {
    Install-Script Get-AutopilotDiagnosticsCommunity -Force
    Write-Output 'Get-AutopilotDiagnosticsCommunity Installed OK'
    exit 0
}
catch {
    Write-Error "Get-AutopilotDiagnosticsCommunity Install - $($_.Exception | Out-String)"
    Stop-Transcript
    exit 0
}
#endregion Windows Diagnostics Community