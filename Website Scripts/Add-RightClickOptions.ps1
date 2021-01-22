<#
.SYNOPSIS
   Add Options to the right click menu
.DESCRIPTION
   Can be used to add options to the right click menu on WIndows Systems
.AUTHOR
    Jonathan Fallis
.VERSION
    1.0.1 - Changed the script to have a parameter option and to make into a tool
.EXAMPLE
    .\Add-PinnedItemsToTaskbar -Option CopyTo
    .\Add-PinnedItemsToTaskbar -Option MoveTo
    .\Add-PinnedItemsToTaskbar -Option CMDHere
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('CopyTo','MoveTo', 'CMDHere')]
    [string]$Option
)

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

Switch ($Option) {
    "CopyTo" {New-Item "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{C2FBB630-2971-11D1-A18C-00C04FD75D13}" -Force}
    "MoveTo" {New-Item "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{C2FBB631-2971-11D1-A18C-00C04FD75D13}" -Force}
    "CMDHere" {New-Item "HKCR:\Folder\shell\Open Command Prompt Here\command\" -Force; Set-Item "HKCR:\Folder\shell\Open Command Prompt Here\command\" -Value "cmd.exe /k pushd %L"}

}
