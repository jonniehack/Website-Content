<#
.SYNOPSIS
    Installs Get-WindowsAuopilotInfo.ps1 and calls it using the parameter
.DESCRIPTION
    * Used alongside a task sequence within Configuration Manager, this script was uses to add the device to autopilot and set a GroupTa
.AUTHOR
    Jonathan Fallis - www.deploymentshare.com
.VERSION
    1.0.1 - Added Error Logging
    1.0.0 - Original
.EXAMPLE
    .\Set-AutopilotGroupTag -TenantID "123456" -AppID "234567" -SecretID "345678" -GroupTag "AutopilotDevice"
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$TenantID,
    [Parameter(Mandatory=$true)]
    [string]$AppID,
    [Parameter(Mandatory=$true)]
    [string]$SecretID,
    [Parameter(Mandatory=$true)]
    [string]$GroupTag
)


$WorkingDir = $env:TEMP
$LogFilePath = "C:\Windows\Temp\Set-GroupTag.log"
[System.Environment]::SetEnvironmentVariable('LOCALAPPDATA',"$env:SystemDrive\Windows\system32\config\systemprofile\AppData\Local")

#Function for Error Logging
Function Write-log {

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)]
        [String]$Path,

        [parameter(Mandatory = $true)]
        [String]$Message,

        [parameter(Mandatory = $true)]
        [String]$Component,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Info', 'Warning', 'Error')]
        [String]$Type
    )

    switch ($Type) {
        'Info' { [int]$Type = 1 }
        'Warning' { [int]$Type = 2 }
        'Error' { [int]$Type = 3 }
    }

    # Create a log entry
    $Content = "<![LOG[$Message]LOG]!>" + `
        "<time=`"$(Get-Date -Format 'HH:mm:ss.ffffff')`" " + `
        "date=`"$(Get-Date -Format 'M-d-yyyy')`" " + `
        "component=`"$Component`" " + `
        "context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " + `
        "type=`"$Type`" " + `
        "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadId)`" " + `
        "file=`"`">"

    # Write the line to the log file
    Add-Content -Path $Path -Value $Content
}

#Test for internet connectivty using 8.8.8.8
If (Test-Connection 8.8.8.8 -quiet) {
    Write-Log -Type Info -Message "Internet Connection OK" -Component "Internet Check" -Path $LogFilePath
}
Else {
    Write-Log -Type Error -Message "Internet Connection check failed" -Component "Internet Check" -Path $LogFilePath ; Exit 1 
}

#Enable TLS 1.2
Try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Log -Type Info -Message "Setting TLS1.2 Completed Successfully" -Component "TLS 1.2 Check" -Path $LogFilePath
    }
Catch {
        Write-Log -Type Error -Message ($_ | Out-String) -Component "TLS 1.2 Check" -Path $LogFilePath
}

#PowerShellGet from PSGallery URL
Try {
    if (!(Get-Module -Name PowerShellGet)){
        $PowerShellGetURL = "https://psg-prod-eastus.azureedge.net/packages/powershellget.2.2.5.nupkg"
        Write-Log -Type Info -Message "URL set to $PowerShellGetURL" -Component "PowerShellGet Check" -Path $LogFilePath
        Invoke-WebRequest -UseBasicParsing -Uri $PowerShellGetURL -OutFile "$WorkingDir\powershellget.2.2.5.zip"
        Write-Log -Type Info -Message "Downloaded PowerShellGet " -Component "PowerShellGet Check" -Path $LogFilePath
        $Null = New-Item -Path "$WorkingDir\2.2.5" -ItemType Directory -Force
        Expand-Archive -Path "$WorkingDir\powershellget.2.2.5.zip" -DestinationPath "$WorkingDir\2.2.5"
        Write-Log -Type Info -Message "Unzipped PowerShellGet " -Component "PowerShellGet Check" -Path $LogFilePath
        $Null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet" -ItemType Directory -ErrorAction SilentlyContinue
        Move-Item -Path "$WorkingDir\2.2.5" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PowerShellGet\2.2.5"
        Write-Log -Type Info -Message "Moved PowerShellGet to $WorkingDir" -Component "PowerShellGet Check" -Path $LogFilePath
        }
}
Catch {
    Write-Log -Type Error -Message ($_ | Out-String) -Component "PowerShellGet Check" -Path $LogFilePath
}

#PackageManagement from PSGallery URL
Try {
    if (!(Get-Module -Name PackageManagement)){
        $PackageManagementURL = "https://psg-prod-eastus.azureedge.net/packages/packagemanagement.1.4.7.nupkg"
        Write-Log -Type Info -Message "URL set to $PackageManagementURL" -Component "PackageManagement Check" -Path $LogFilePath
        Invoke-WebRequest -UseBasicParsing -Uri $PackageManagementURL -OutFile "$WorkingDir\packagemanagement.1.4.7.zip"
        Write-Log -Type Info -Message "Downloaded PackageManagement" -Component "PackageManagement Check" -Path $LogFilePath
        $Null = New-Item -Path "$WorkingDir\1.4.7" -ItemType Directory -Force
        Expand-Archive -Path "$WorkingDir\packagemanagement.1.4.7.zip" -DestinationPath "$WorkingDir\1.4.7"
        Write-Log -Type Info -Message "Unzipped PackageManagement" -Component "PackageManagement Check" -Path $LogFilePath
        $Null = New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement" -ItemType Directory -ErrorAction SilentlyContinue
        Move-Item -Path "$WorkingDir\1.4.7" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\PackageManagement\1.4.7"
        Write-Log -Type Info -Message "Moved PackageManagement to $WorkingDir" -Component "PackageManagement Check" -Path $LogFilePath
        }
}
Catch {
    Write-Log -Type Error -Message ($_ | Out-String) -Component "PackageManagement Check" -Path $LogFilePath
}

#Import PowerShellGet
if (Import-Module PowerShellGet) {
    Write-Log -Type Info -Message "PowerShellGet Module Imported OK" -Component "PowerShellGet Import" -Path $LogFilePath
}
Else {
    Write-Log -Type Error -Message ($_ | Out-String) -Component "PowerShellGet Import" -Path $LogFilePath ; Exit 1 
}

#Install the script
if (Install-Script Get-WindowsAutopilotinfo -Force) {
    Write-Log -Type Info -Message "Get-WindowsAutopilotInfo Installed OK" -Component "Get-WindowsAutopilotInfo Install" -Path $LogFilePath
}
Else {
    Write-Log -Type Error -Message ($_ | Out-String) -Component "Get-WindowsAutopilotInfo Install" -Path $LogFilePath ; Exit 1 
}

#Run the script
if (Get-WindowsAutopilotinfo -Online -TenantId $TenantID -AppId $AppID -AppSecret $SecretID -Grouptag $GroupTag) {
    Write-Log -Type Info -Message "Get-WindowsAutopilotInfo executed successfully" -Component "Running Get-WindowsAutopilotInfo" -Path $LogFilePath
}
Else {
    Write-Log -Type Error -Message ($_ | Out-String) -Component "Get-WindowsAutopilotInfo Install" -Path $LogFilePath ; Exit 1 
}