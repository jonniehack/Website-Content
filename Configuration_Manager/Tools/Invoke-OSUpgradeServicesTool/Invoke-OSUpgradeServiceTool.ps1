<#PSScriptInfo

.VERSION 0.0.6

.AUTHOR Jonathan Fallis

.RELEASENOTES
v0.0.6 - Updated Start and Stop-Services to stop outputting batch job in Get-Services
v0.0.5 - Updated Start-Services function to wait and handle start-pending.
v0.0.4 - Updated Stop-Service function to handle StopPending
v0.0.3 - Updated Services variable.
v0.0.2 - Created a batch job for stopping ans starting services.
v0.0.1 - Initial release.

#>

$Services = @(
        
    # Configuration Manager SMS Services
    'SMS_EXECUTIVE',
    'SMS_SITE_COMPONENT_MANAGER',
    'SMS_NOTIFICATION_SERVER',
    'SMS_POLICY_PROVIDER',
    'SMS_STATE_SYSTEM',
    'SMS_MP_CONTROL_MANAGER',
    'SMS_SITE_SQL_BACKUP',
    'SMS_SITE_VSS_WRITER',

    # IIS Services
    'W3SVC', 
    'WAS',

    # SQL Services
    'MSSQLSERVER',
	'SQLSERVERAGENT',
	'SQLBrowser',
	'ReportServer', # Change if you use named instance (e.g., 'ReportServer$INSTANCE')
    'SQLWriter'

) # Services List

Function Invoke-Relaunch {

 # Relaunch
    do {
    Clear-Variable -Name choice* -ErrorAction SilentlyContinue
    Write-Host "`n Would you like to re-launch the script?" -ForegroundColor White
    Write-Host "`n  (N) No - Exit" -ForegroundColor Red
    Write-Host "`n  (Y) Yes - Relaunch" -ForegroundColor Green

    $choice = Read-Host -Prompt "`n Type Y or N, then press enter"

    } while ($choice -notin ('Y', 'N'))

    switch ($choice) {
        'N' { break }
        'Y' { Invoke-Menu }
    } # Switch

} # Invoke-Relaunch

Function Get-Services {

    Clear-Host

    try {

        # Get services and their state
        Write-Host "`n Here are the services and their current state for review"
        Get-CimInstance -ClassName Win32_Service |
        Where-Object { $Services -contains $_.Name } |
        Select-Object Name, State, StartMode |
        Format-Table -AutoSize
    }
    catch {
	    Write-Host "Failed to get Service $svc $($_.Exception.Message)" -ForegroundColor Yellow
    }

    Invoke-Relaunch

} # Get-Services

Function Stop-Services {

    $jobList = [System.Collections.Generic.List[object]]::new()

    foreach ($svc in $Services) {
        Write-Host "Processing service: $svc..." -ForegroundColor Cyan

        $serviceObj = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if (-not $serviceObj) {
            Write-Host "Service '$svc' not found, skipping..." -ForegroundColor DarkYellow
            continue
        }

        try {
            Set-Service -Name $svc -StartupType Disabled
            Write-Host "$svc set to Disabled startup." -ForegroundColor Yellow
        }
        catch {
            Write-Host "Failed to configure $svc $($_.Exception.Message)" -ForegroundColor Red
            continue
        }

        try {
            $job = Start-Job -ScriptBlock {
                param($ServiceName)
                Stop-Service -Name $ServiceName -Force
            } -ArgumentList $svc
            $null = $jobList.Add($job)
        }
        catch {
            Write-Host "Failed to queue background job for $svc $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`n Waiting for all stop jobs to finish..." -ForegroundColor White
    Wait-Job -Job $jobList | Out-Null

    # Suppress job output completely
    Receive-Job -Job $jobList | Out-Null
    Remove-Job -Job $jobList | Out-Null

    Get-Services

} # Stop-Services v3

Function Start-Services {

    $jobList = [System.Collections.Generic.List[object]]::new()

    foreach ($svc in $Services) {
        Write-Host "Processing service: $svc..." -ForegroundColor Cyan

        $serviceObj = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if (-not $serviceObj) {
            Write-Host "Service '$svc' not found, skipping..." -ForegroundColor DarkYellow
            continue
        }

        try {
            Set-Service -Name $svc -StartupType Automatic
            Write-Host "$svc set to Automatic startup." -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to configure $svc $($_.Exception.Message)" -ForegroundColor Yellow
            continue
        }

        try {
            $job = Start-Job -ScriptBlock {
                param($ServiceName)
                Start-Service -Name $ServiceName
            } -ArgumentList $svc
            $null = $jobList.Add($job)
        }
        catch {
            Write-Host "Failed to queue background job for $svc $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`n Waiting for all background jobs to finish..." -ForegroundColor White
    Wait-Job -Job $jobList | Out-Null

    # Suppress job output completely
    Receive-Job -Job $jobList | Out-Null
    Remove-Job -Job $jobList | Out-Null

    Get-Services

} # Start-Services v3

Function Invoke-Menu {
    do {
        Clear-Variable -Name choice* -ErrorAction SilentlyContinue
        Clear-Host
        Write-Host "  _____                 _            _______          _ "
        Write-Host " / ____|               (_)          |__   __|        | |"
        Write-Host "| (___   ___ _ ____   ___  ___ ___     | | ___   ___ | |"
        Write-Host " \___ \ / _ \ '__\ \ / / |/ __/ _ \    | |/ _ \ / _ \| |"
        Write-Host " ____) |  __/ |   \ V /| | (_|  __/    | | (_) | (_) | |"
        Write-Host "|_____/ \___|_|    \_/ |_|\___\___|    |_|\___/ \___/|_|"
                                                         
        Write-Host "`n Intended to be used to stop services in preparation for an Operating System upgrade `n on a Configuration Manager server or to start them after the upgrade." -ForegroundColor White
        Write-Host "`n >>> Ensure you have checked the 'Services' variable. <<<" -ForegroundColor Yellow
        Write-Host "`n Select which action:" -ForegroundColor White
        Write-Host "`n  (1) Stop Services BEFORE an Operating System Upgrade" -ForegroundColor Red
        Write-Host "`n  (2) Start Services AFTER an Operating System Upgrade" -ForegroundColor Green
        Write-Host "`n  (3) Review Services" -ForegroundColor Cyan
        Write-Host "`n  (E) Exit`n" -ForegroundColor White

        $choice = Read-Host -Prompt 'Based on choices above, type 1, 2, or E to exit the script, then press enter'

    } while ($choice -notin ('1', '2', '3', 'E'))

    switch ($choice) {
        'E' { exit }
        '1' { Stop-Services }
        '2' { Start-Services }
        '3' { Get-Services }
    }

} # Invoke-Menu

#################
# CALL FUNCTION #
#################

Invoke-Menu