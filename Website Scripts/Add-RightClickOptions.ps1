<#
Script to create add more options to your right click menu

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

#>
Function Add-RightClickOptions    
    {   
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT   
        New-Item "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{C2FBB630-2971-11D1-A18C-00C04FD75D13}" -Force # Copy to Folder...   
        New-Item "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{C2FBB631-2971-11D1-A18C-00C04FD75D13}" -Force # Move to Folder...   
        New-Item "HKCR:\Folder\shell\Open Command Prompt Here\command\" -Force   
        Set-Item "HKCR:\Folder\shell\Open Command Prompt Here\command\" -Value "cmd.exe /k pushd %L" # Open CMD Prompt Here...   
    } # Close Function   
  
Add-RightClickOptions