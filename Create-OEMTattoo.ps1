<#
Script to create your OEM folder and set Branding Tattoo Options

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

Notes:  
1. Change the middle function to point to your OEM Picture location
2. Your OEM Picture must meet the requirements of size

#>
Function Create-OEMFolder   
	{   
		$Destination = "C:\Windows\OEM"   
		if (!(Test-Path -path $Destination )) { $null = New-Item -ItemType Container -Path $Destination -Force }   
		Copy-Item .\OEM.bmp $Destination -Force   
	}

Function Copy-PicturetoLocation
    {
    $Source = #SET YOUR PICTURE SOURCE LOCATION HERE
    $Destination = "C:\Windows\OEM\"
    Robocopy $Source $Destination
    }

Function Set-OEMBranding  
    {   
        $OEMKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"   
        Set-ItemProperty -Path $OEMKey -Name "Model" -Value (Get-WmiObject -Class Win32_ComputerSystem).Model   
        Set-ItemProperty -Path $OEMKey -Name "HelpCustomized" -Value 00000000   
        Set-ItemProperty -Path $OEMKey -Name "SupportHours" -Value "Here at www.deploymentshare.com we are always open"   
        Set-ItemProperty -Path $OEMKey -Name "Logo" -Value "C:\Windows\OEM\oem.bmp"   
        Set-ItemProperty -Path $OEMKey -Name "Manufacturer" -Value "Deploymentshare.com"   
        Set-ItemProperty -Path $OEMKey -Name "SupportPhone" -Value "0123 456 78910"  
        Set-ItemProperty -Path $OEMKey -Name "SupportURL" -Value "http://www.deploymentshare.com"  
    }

Create-OEMFolder
Copy-PicturetoLocation
Set-OEMBranding