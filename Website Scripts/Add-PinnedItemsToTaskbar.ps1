<#
.SYNOPSIS
   Pin items to the task bar of Server 2012R2 servers during OSD
.DESCRIPTION
   Only tested on Server 2012R2, this sript can be used to pin objects to the taskbar.
   I've included some common ones to use
.AUTHOR
    Jonathan Fallis
.VERSION
    1.0.0
.EXAMPLE
   
#>
 
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Internet Explorer','MDT', 'ADUAC', 'DHCP', 'DNS', 'GPO', 'WSUS', 'WDS')]
    [string]$Option
)

#Constants
$shell = new-object -com 'Shell.Application'  

#Array
$MultiDimentionalArray = 
    @(
    # Internet Explorer    
        '$folder = $shell.Namespace("C:\Program Files\Internet Explorer");',  
        '$item = $folder.Parsename("iexplore.exe")'
    ),@(
    # MDT Deployment Workbench  
        '$folder = $shell.Namespace("C:\Program Files\Microsoft Deployment Toolkit\Bin");',
        '$item = $folder.Parsename("DeploymentWorkbench.msc")'
    ),@(
    # AD Users and Computers  
        '$folder = $shell.Namespace("c:\windows\system32");',
        '$item = $folder.Parsename("dsa.msc")'
    ),@(
    # DHCP  
        '$folder = $shell.Namespace("c:\windows\system32");',
        '$item = $folder.Parsename("dhcpmgmt.msc")'
    ),@(
    # DNS  
        '$folder = $shell.Namespace("c:\windows\system32");',  
        '$item = $folder.Parsename("dnsmgmt.msc")'
    ),@(
    # Group Policy  
        '$folder = $shell.Namespace("c:\windows\system32");',  
        '$item = $folder.Parsename("gpmc.msc")'
    ),@(
    # WSUS  
        '$folder = $shell.Namespace("c:\program files\update services\administrationSnapin");',  
        '$item = $folder.Parsename("wsus.msc")'
    ),@(
    # WDS
        '$folder = $shell.Namespace("c:\windows\system32");',  
        '$item = $folder.Parsename("WdsMgmt.msc")'
    )

$Pin = '$item.invokeverb("taskbarpin")'


#Switch Options
    #0 = Internet Explorer
    #1 - MDT Deployment Workbench
    #2 - AD Users and Computers
    #3 - DHCP
    #4 - DNS
    #5 - Group Policy Editor
    #6 - WSUS
    #7 - WDS

Switch ($Option) {
    "0" {$MultiDimentionalArray[0]; $Pin}
    "1" {$MultiDimentionalArray[1]; $Pin}
    "2" {$MultiDimentionalArray[2]; $Pin}
    "3" {$MultiDimentionalArray[3]; $Pin}
    "4" {$MultiDimentionalArray[4]; $Pin}
    "5" {$MultiDimentionalArray[5]; $Pin}
    "6" {$MultiDimentionalArray[6]; $Pin}
    "7" {$MultiDimentionalArray[7]; $Pin}

}
