<#
Script to Pin Programs to the taskbar
I am testing a GitHub Change
Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

#>
$shell = new-object -com "Shell.Application"    

# Internet Explorer    
$folder = $shell.Namespace('c:\program files\internet explorer')   
$item = $folder.Parsename('iexplore.exe')  
$item.invokeverb('taskbarpin')  

# MDT Deployment Workbench  
$folder = $shell.Namespace('C:\Program Files\Microsoft Deployment Toolkit\Bin')  
$item = $folder.Parsename('DeploymentWorkbench.msc')  
$item.invokeverb('taskbarpin')  

# AD Users and Computers  
$folder = $shell.Namespace('c:\windows\system32')  
$item = $folder.Parsename('dsa.msc')  
$item.invokeverb('taskbarpin')  

# DHCP  
$folder = $shell.Namespace('c:\windows\system32')  
$item = $folder.Parsename('dhcpmgmt.msc')  
$item.invokeverb('taskbarpin')  

# DNS  
$folder = $shell.Namespace('c:\windows\system32')  
$item = $folder.Parsename('dnsmgmt.msc')  
$item.invokeverb('taskbarpin')  

# Group Policy  
$folder = $shell.Namespace('c:\windows\system32')  
$item = $folder.Parsename('gpmc.msc')  
$item.invokeverb('taskbarpin')  

# WSUS  
$folder = $shell.Namespace('c:\program files\update services\administrationSnapin')  
$item = $folder.Parsename('wsus.msc')  
$item.invokeverb('taskbarpin')  

# WDS
$folder = $shell.Namespace('c:\windows\system32')  
$item = $folder.Parsename('WdsMgmt.msc')  
$item.invokeverb('taskbarpin')