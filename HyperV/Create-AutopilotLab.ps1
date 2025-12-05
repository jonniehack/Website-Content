<#PSScriptInfo

.VERSION 0.0.1

.AUTHOR Jonathan Fallis

.RELEASENOTES
v0.0.1 - Initial release of AutopilotLab Tool.

.NOTES
    Check Pre-requisites for running the tool
    Setup Folder Structure
    Prompt to download ISOs
    Rename ISOs to be neater
    Create a VM Template from the ISO
        Set VM Properties
    Install scripts and sysprep/shutdown
        Install-Script -Name Get-WindowsAutopilotInfoCommunity -Repository PSGallery -Scope AllUsers -Force -Confirm:$false
        Install-Script -Name Get-AutopilotDiagnostics -Repository PSGallery -Scope AllUsers -Force -Confirm:$false 
    Copy/Rename Template VHD
    Create a new Autopilot test VM
        Use template VHD of your choice
        Set VM properties

#>

$Version = "0.0.1"
$BasePath   = "D:\VIRTUAL_MACHINES\LAB" # Root path for all VMs
$ToolsPath  = "D:\VIRTUAL_MACHINES\TOOLS"
$ClientIsoPath = "$ToolsPath\ISO_STORE_OS_CLIENT" # Root path for all Client Operating System ISOs
$ServerIsoPath = "$ToolsPath\ISO_STORE_OS_SERVER" # Root path for all Server Operating System ISOs          
$VhdFolder  = Join-Path $VMRootPath "Virtual Harddisks"
$SwitchName = "EXTERNAL NETWORK"

#---------------------Begin---------------------#

#region Menus
Function Invoke-Header {
        Clear-Variable -Name choice* -ErrorAction SilentlyContinue

        Clear-Host
                                            
        Write-Host "  _    _                    __      __  _           _       _______          _ "
        Write-Host " | |  | |                   \ \    / / | |         | |     |__   __|        | |"
        Write-Host " | |__| |_   _ _ __   ___ _ _\ \  / /  | |     __ _| |__      | | ___   ___ | |"
        Write-Host " |  __  | | | | '_ \ / _ \ '__\ \/ /   | |    / _  | '_ \     | |/ _ \ / _ \| |"
        Write-Host " | |  | | |_| | |_) |  __/ |   \  /    | |___| (_| | |_) |    | | (_) | (_) | |"
        Write-Host " |_|  |_|\__, | .__/ \___|_|    \/     |______\__,_|_.__/     |_|\___/ \___/|_|"
        Write-Host "          __/ | |                                                              "
        Write-Host "         |___/|_|                                                              "
        Write-Host "`n        >>> Version $Version | To be run on the HyperV Server server <<<" -ForegroundColor Yellow

} # Invoke-Header - Needs Editing

Function Invoke-MainMenu {

    while ($true) {
        Invoke-Header
        Write-Host "`n Please chose from the following options:" -ForegroundColor White
        Write-Host "`n  (1) Create a new" -NoNewline ; Write-Host " VM Template" -ForegroundColor Yellow
        Write-Host "`n  (E) Exit"
        Write-Host "`n  (A) About the script"
        
        $choice = Read-Host "`n Select an option"

        switch ($choice.ToUpper()) {
            '1' { New-LabVMTemplate }

            'E' { Write-Host "Exiting script..." ; Start-Sleep 1 ; return }
            'A' { Invoke-AboutScript }
            default { Write-Warning "Invalid selection. Please try again..." ; Start-Sleep 1}
        }
    }
} # Invoke-MainMenu

Function Invoke-Pause {

    try {
        if ($Host.Name -notmatch 'ISE' -and $Host.Name -notmatch 'Visual Studio Code') {
            # True console host: instant key capture (no Enter required)
            Write-Host "`nPress any key to continue..." -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        else {
            # ISE or VS Code: fallback that requires Enter
            Write-Host "`nPress Enter to continue..." -ForegroundColor DarkGray
            Read-Host | Out-Null
        }
    }
    catch {
        # Ultra-safe fallback (e.g. remote sessions)
        Write-Host "`nPress Enter to continue..." -ForegroundColor DarkGray
        Read-Host | Out-Null
    }
} # Invoke-Pause (Press any key to continue)
#endregion

Function Get-LabVMISOImages{ 
}

Function Invoke-LabVMPreRequisites {

    Clear-Host
    Invoke-Header
    Write-Host "`nChecking prerequisites..." -ForegroundColor Cyan

    # -------------------------
    # Check: Running as Admin
    # -------------------------
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
                [Security.Principal.WindowsIdentity]::GetCurrent()
               ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host "`n[ERROR] This script must be run as Administrator." -ForegroundColor Red
        return $false
    }

    Write-Host " ✔ Running with administrative privileges." -ForegroundColor Green


    # -------------------------
    # Check: Hyper-V Module installed
    # -------------------------
    if (-not (Get-Module -ListAvailable -Name Hyper-V)) {
        Write-Host "`n[ERROR] Hyper-V PowerShell module is not installed." -ForegroundColor Red
        return $false
    }

    Write-Host " ✔ Hyper-V PowerShell module is available." -ForegroundColor Green


    # -------------------------
    # Check: Hyper-V Role Enabled
    # -------------------------
    $hvEnabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All | Select-Object -ExpandProperty State

    if ($hvEnabled -ne "Enabled") {
        Write-Host "`n[ERROR] Hyper-V is installed but NOT enabled." -ForegroundColor Red
        Write-Host "Enable it with:" -ForegroundColor Yellow
        Write-Host "  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart" -ForegroundColor DarkGray
        Write-Host ""
        return $false
    }

    Write-Host " ✔ Hyper-V Role is enabled." -ForegroundColor Green
    Start-Sleep 2

    Invoke-MainMenu
} # Invoke-LabVMPreRequisites - FINISHED

Function Invoke-LabVMTemplateProperties {
    
    # Set vCPUs to 8
    Set-VMProcessor -VMName $VMName -Count 8

    # Dynamic memory
    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true `
                 -MinimumBytes 2GB -StartupBytes $MemoryStartup -MaximumBytes 16GB

    # Disable automatic checkpoints
    Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false

    # Secure Boot
    Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate "MicrosoftWindows"

    # TPM attempt
    $TPMStatus = "Disabled or unavailable"
    try {
        Enable-VMTPM -VMName $VMName -ErrorAction Stop
        $TPMStatus = "Enabled"
    }
    catch {
        try {
            Set-VMKeyProtector -VMName $VMName -NewLocalKeyProtector -ErrorAction Stop
            Enable-VMTPM -VMName $VMName -ErrorAction Stop
            $TPMStatus = "Enabled"
        }
        catch {
            Write-Warning "TPM could not be enabled on this host for VM '$VMName'."
        }
    }
}

Function New-LabVMTemplate {
    
    Clear-Host
    Invoke-Header

    # Collect ISOs from both locations
    $isoList = @()

    # Get Client ISO List and add to Array
    if (Test-Path $ClientIsoPath) {
        $isoList += Get-ChildItem -Path $ClientIsoPath -Filter *.iso -File |
            Select-Object @{Name='DisplayName';Expression={"Client - " + $_.Name}},
                          @{Name='FullName';Expression={$_.FullName}}
    }

    # Get Server ISO List and add to Array
    if (Test-Path $ServerIsoPath) {
        $isoList += Get-ChildItem -Path $ServerIsoPath -Filter *.iso -File |
            Select-Object @{Name='DisplayName';Expression={"Server - " + $_.Name}},
                          @{Name='FullName';Expression={$_.FullName}}
    }

    # Error if no ISOs found
    if (-not $isoList -or $isoList.Count -eq 0) {
        Write-Error "No ISO files found in:
        $ClientIsoPath
        $ServerIsoPath"
        return
    }

    # Prompt user to choose ISO
    Write-Host ""
    Write-Host "Chose one of the Available ISO images:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $isoList.Count; $i++) {
        $index = $i + 1
        Write-Host ("`n  [{0}] {1}" -f $index, $isoList[$i].DisplayName)
    }

    do {
        $choice = Read-Host "`nEnter the number of the ISO you want to use"
        [int]$choiceValue = 0
        $isNumber = [int]::TryParse($choice, [ref]$choiceValue)
    } until ($isNumber -and $choiceValue -ge 1 -and $choiceValue -le $isoList.Count)

    $selectedIso = $isoList[$choiceValue - 1]
    $isoFullPath = $selectedIso.FullName

    # Derive VM name from ISO name: _Template-<ISONameWithoutExtension>
    $isoBaseName = [System.IO.Path]::GetFileNameWithoutExtension($isoFullPath)
    $VMName = "_Template-$isoBaseName"

    Write-Host ""
    Write-Host "Using ISO:" -ForegroundColor Yellow
    Write-Host "  $isoFullPath"
    Write-Host "VM will be created as:" -ForegroundColor Yellow
    Write-Host "  $VMName"
    Write-Host ""

    # Validate switch
    if (-not (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue)) {
        Write-Error "Hyper-V switch '$SwitchName' not found. Create it first."
        return
    }

    # Prevent duplicate VM names
    if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
        Write-Error "A VM named '$VMName' already exists."
        return
    }

    # Create VHD folder (Hyper-V will create the VM folder + 'Virtual Machines' under $BasePath)
    $null = New-Item -ItemType Directory -Path $VhdFolder -Force

    # VM configuration
    $VhdPath       = Join-Path $VhdFolder "$VMName.vhdx"
    $MemoryStartup = 8GB
    $VhdSize       = 80GB

    # Create VHD
    Write-Host "Creating virtual disk: $VhdPath"
    New-VHD -Path $VhdPath -SizeBytes $VhdSize -Dynamic | Out-Null

    # Create VM (Path is the base folder so we don't get double-nested VM folders)
    Write-Host "Creating VM $VMName..."
    New-VM -Name $VMName `
           -Generation 2 `
           -MemoryStartupBytes $MemoryStartup `
           -Path $BasePath `
           -VHDPath $VhdPath `
           -SwitchName $SwitchName | Out-Null

    Invoke-LabVMTemaplateProperties

    # Attach ISO
    Add-VMDvdDrive -VMName $VMName -Path $isoFullPath | Out-Null

    # Boot from DVD first
    $dvd = Get-VMDvdDrive -VMName $VMName
    Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd

    # Compute config path for summary
    $vmConfigPath = Join-Path $VMRootPath "Virtual Machines"

    # Output Summary

    Clear-Host
    Invoke-Header
    Write-Host "`nVM created successfully!" -ForegroundColor Green
    Write-Host "--------------------------------------"
    Write-Host "VM Name       : $VMName"
    Write-Host "VM Root       : $VMRootPath"
    Write-Host "Config Path   : $vmConfigPath"
    Write-Host "VHD Folder    : $VhdFolder"
    Write-Host "VHD Path      : $VhdPath"
    Write-Host "Disk Size     : 80GB Dynamic"
    Write-Host "Memory        : 8GB Dynamic (2GB–16GB)"
    Write-Host "vCPUs         : 8"
    Write-Host "TPM           : $TPMStatus"
    Write-Host "Network       : $SwitchName"
    Write-Host "ISO Attached  : $isoFullPath"

    Invoke-Pause
}

###############
# CALL SCRIPT #
###############

Invoke-LabVMPreRequisites
