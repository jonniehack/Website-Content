<#
Script to deploy a deploymentshare

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

Purpose:  
    1. To deploy a new deploymentshare, 
    2. Create a linked share on the deploy server (c:\deploymentshare$)
    3. Replicate content from deploy server to new share
    4. Replicate only the content selected in the selection profile
 
Prerequisites:
    1. Selection profile MUST already exist on deploy server
    2. Edit the four variables for your network
#>
 
    # EDIT THESE FOR YOUR NETWORK
$SourceServer = "Server1"
$DestinationServer = "Server2"
$SourceDeploymentshare = "\\Server1\deploymentshare$"
$SelectionProfileName = "Basic Share" 
 
   
  # IMPORT MODULES AND SET DESTINATION
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1" -ErrorAction SilentlyContinue
Import-Module SmbShare
$DestinationDeploymentshare = "\\" + $DestinationServer + "\deploymentshare$"
 
  # CREATE NEW SHARE ON TARGET SERVER
$sharePath = "C:\DEPLOYMENTSHARE$"
New-Item $sharePath -ItemType directory -Verbose
New-SmbShare -Name DEPLOYMENTSHARE$ -Path $sharePath -FullAccess Everyone -Verbose
 
  # CREATE NEW DEPLOYMENTSHARE (ON ROOT OF C:\)
New-PSDrive -Name "DS001" -PSProvider MDTProvider �Root "C:\DEPLOYMENTSHARE$" -Description "Deploymentshare" -Verbose | add-MDTPersistentDrive -Verbose
 
  # ADD LINKED SHARE TO DEPLOY SERVER
New-PSDrive -Name "DESTDEPSHARE" -PSProvider MDTProvider -root $SourceDeploymentshare -Verbose
New-Item -path "DESTDEPSHARE:\Linked Deployment Shares" -enable "True" -Name $DestinationServer -Comments "" -Root $DestinationDeploymentshare -SelectionProfile "BASIC SHARE" -Replace "True" -CopyStandardFolders "True" -UpdateBoot "False" -Verbose
 
  # REPLICATE
$Replicate ="DESTDEPSHARE:\Linked Deployment Shares\" + $SelectionProfileName
Update-MDTLinkedDS -Path $Replicate -Verbose
