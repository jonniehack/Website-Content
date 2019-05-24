<#
Script to disable update notifications for Flash

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

#>
Function Disable-FlashUpdateNotifications
    {
       $Test = Test-Path C:\Windows\SysWOW64\Macromed\Flash
       if($Test)
            {
            New-Item -ItemType file -path "C:\Windows\SysWOW64\Macromed\Flash\mms.cfg"
            Set-content -path "C:\Windows\SysWOW64\Macromed\Flash\mms.cfg" -value "AutoUpdateDisable=1", "SilentAutoUpdateEnable=0"
            } # Close IF
       $Test2 = Test-Path C:\WINDOWS\System32\Macromed\Flash
       if($Test2)
            {
            New-Item -ItemType file -path "C:\WINDOWS\System32\Macromed\Flash\mms.cfg"
            Set-content -path "C:\WINDOWS\System32\Macromed\Flash\mms.cfg" -value "AutoUpdateDisable=1", "SilentAutoUpdateEnable=0"
            } # Close IF
    } # Close Function

Disable-FlashUpdateNotifications