<#
Script to disable update notifications for Java

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

#>
Function Disable-JavaUpdateNotifications   
	{   
	Switch ($env:PROCESSOR_ARCHITECTURE) {   
		("AMD64") {   
			$DJUN = "HKLM:\SOFTWARE\Wow6432Node\JavaSoft\Java Update\Policy"   
			Set-ItemProperty -Path $DJUN -Name "EnableJavaUpdate" -Value 0   
			Set-ItemProperty -Path $DJUN -Name "NotifyDownload" -Value 0   
			New-ItemProperty $DJUN -Name "EnableAutoUpdateCheck" -Value 0 -PropertyType "DWord"    
			} # Close x64  
		("x86") {  
			$DJUN = "HKLM:\SOFTWARE\JavaSoft\Java Update\Policy"  
			Set-ItemProperty -Path $DJUN -Name "EnableAutoUpdateCheck" -Value 0  
			Set-ItemProperty -Path $DJUN -Name "EnableJavaUpdate" -Value 0  
			} # Close x86  
		} # Close Switch  
	}# Close Function  
    
Disable-JavaUpdateNotifications