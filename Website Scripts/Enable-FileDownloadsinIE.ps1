<#
Script to enable file downloads in IE

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

Purpose:  
    1. To enable the ability to download files in IE after deployment
#>
Function Enable-IEFileDownload
	{
		$HKLM = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
		$HKCU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3"
		Set-ItemProperty -Path $HKLM -Name "1803" -Value 0
		Set-ItemProperty -Path $HKCU -Name "1803" -Value 0
	}

Enable-IEFileDownload
