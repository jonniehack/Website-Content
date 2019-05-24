<#
Script to enable RDP on servers after deployment

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

#>
Function Enable-RDP   
	{   
		$HKLM1 = "HKLM:\System\CurrentControlSet\Control\Terminal Server"   
		$HKLM2 = "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"   
		Set-ItemProperty -Path $HKLM1 -Name "fDenyTSConnections" -Value 0   
		Set-ItemProperty -Path $HKLM2 -Name "UserAuthentication" -Value 0   
	}   
 
Enable-RDP