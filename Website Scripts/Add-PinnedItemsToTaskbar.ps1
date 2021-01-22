<#
.SYNOPSIS
   Pin items to the task bar of Server 2012R2 servers during OSD
.DESCRIPTION
   Only tested on Server 2012R2, this sript can be used to pin objects to the taskbar.
   I've included some common ones to use
.AUTHOR
    Jonathan Fallis
.VERSION
    1.0.1 - Changed the script to have a switch option for calling via params & logic to be used elsewhere
.EXAMPLE
    .\Add-PinnedItemsToTaskbar -Option MDT
    .\Add-PinnedItemsToTaskbar -Option GPO
    .\Add-PinnedItemsToTaskbar -Option DNS
#>
 
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Internet Explorer','MDT', 'ADUAC', 'DHCP', 'DNS', 'GPO', 'WSUS', 'WDS')]
    [string]$Option
)

#Constants
$shell = new-object -com 'Shell.Application'  


Switch ($Option) {
    "0" {$folder = $shell.Namespace("C:\Program Files\Internet Explorer"); $item = $folder.Parsename("iexplore.exe"); $item.invokeverb("taskbarpin")}
    "1" {$folder = $shell.Namespace("C:\Program Files\Microsoft Deployment Toolkit\Bin"); $item = $folder.Parsename("DeploymentWorkbench.msc"); $item.invokeverb("taskbarpin")}
    "2" {$folder = $shell.Namespace("c:\windows\system32"); $item = $folder.Parsename("dsa.msc"); $item.invokeverb("taskbarpin")}
    "3" {$folder = $shell.Namespace("c:\windows\system32"); $item = $folder.Parsename("dhcpmgmt.msc"); $item.invokeverb("taskbarpin")}
    "4" {$folder = $shell.Namespace("c:\windows\system32"); $item = $folder.Parsename("dnsmgmt.msc"); $item.invokeverb("taskbarpin")}
    "5" {$folder = $shell.Namespace("c:\windows\system32"); $item = $folder.Parsename("gpmc.msc"); $item.invokeverb("taskbarpin")}
    "6" {$folder = $shell.Namespace("c:\program files\update services\administrationSnapin"); $item = $folder.Parsename("wsus.msc"); $item.invokeverb("taskbarpin")}
    "7" {$folder = $shell.Namespace("c:\windows\system32"); $item = $folder.Parsename("WdsMgmt.msc"); $item.invokeverb("taskbarpin")}

}
