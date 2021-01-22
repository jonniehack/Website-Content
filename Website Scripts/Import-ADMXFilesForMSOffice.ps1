<#
Script to Import Microsoft Office ADMX Files after deployment

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

Notes:  Edit the source locations to point to the files you need and chose just one to import

#>
Function Import-ADMX   
	{   
		$Destination = "C:\Windows\Sysvol\sysvol\YOURDOMAIN.local\Policies\PolicyDefinitions"   
		$Source = .\ADMX\Office2010x86   
		#$Source = .\ADMX\Office2010x64   
		#$Source = .\ADMX\Office2013x86   
		#$Source = .\ADMX\Office2013x64   
		if (!(Test-Path -path $Destination )) { $null = New-Item -ItemType Container -Path $Destination -Force }   
		Robocopy $Source $Destination /S  
	}  
    
Import-ADMX
