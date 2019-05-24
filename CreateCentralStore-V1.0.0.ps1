<#
Script to create a GPO Central Store after deployment

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

#>
Function Create-CentralStore   
	{   
		$Destination = "C:\Windows\SYSVOL\sysvol\YOURDOMAIN.local\Policies\PolicyDefinitions"   
		$Source = "C:\Windows\PolicyDefinitions"   
		if (!(Test-Path -path $Destination )) { $null = New-Item -ItemType Container -Path $Destination -Force }   
		Robocopy $Source $Destination /S   
	}   
   
Create-CentralStore