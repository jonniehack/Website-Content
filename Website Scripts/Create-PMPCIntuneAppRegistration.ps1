<#
.SYNOPSIS
    Create an app registration in Intune for use with the PMPC Intune Service
.DESCRIPTION
    Create an app registration in Intune for use with the PMPC Intune Service & sets the following permissions
    * Read and write Microsoft Intune apps
    * Read Microsoft Intune devices
    * Read Microsoft Intune RBAC settings
    * Read and write Microsoft Intune configuration
    * Read Group Members
.AUTHOR
    Jonathan Fallis - www.deploymentshare.com
.VERSION
    1.0.0
.EXAMPLE
    .\Create-PMPCIntuneAppRegistration.ps1 -Name "PMPC-AppReg" -SecretYears 1
    .\Create-PMPCIntuneAppRegistration.ps1 -Name "PMPC-AppReg" -SecretYears 3
    .\Create-PMPCIntuneAppRegistration.ps1 -Name "PMPC-AppReg" -SecretYears 5
#>
param (

    #Name of the Application Registration
    [Parameter(Mandatory = $True)]
    [String]$Name,

    #This will create a Secret key for x years and bring back the value to the console
    [Parameter(Mandatory = $True)]
    [ValidateSet("1","3","5")]
    [String]$SecretYears

)

#Global Variables
$Global:TenantDetail

#Import modules if not installed
If (!(Get-Module -Name AzureADPreview -ListAvailable)) {Install-Module -Name AzureADPreview -AllowClobber -Force | Out-Null}

Try 
{
    $TenantDetail = Get-AzureADTenantDetail 
    If ($TenantDetail) 
        {
            Write-Warning "You are connected to tenant $($TenantDetail.DisplayName)"
            Write-Warning "The Tenant ID $($TenantDetail.ObjectID)"
        }
}
Catch
{
    Connect-AzureAD | Out-Null
    $TenantDetail = Get-AzureADTenantDetail 
    If ($TenantDetail) 
        {
            Write-Warning "You are connected to tenant '$($TenantDetail.DisplayName)'"
            Write-Warning "The Tenant ID '$($TenantDetail.ObjectID)'"
        }
}

    #Check for app registration with exisiting name, if not create one.
    Try {
        If (Get-AzureADApplication -Filter "DisplayName eq '$($Name)'") 
            {
                Write-Host -ForegroundColor Red  "You already have an application with the name $($Name)";Break
            }
        Else 
            {
                #Create a service Principal for the type of Permissions - MSGraph
                $MSGraphPrincipal = Get-AzureADServicePrincipal -All $true | Where-Object { $_.AppID -eq "00000003-0000-0000-c000-000000000000" }

                #Create Permission Onjects with GUIDs obtained from Search - ResourceAccess Component
                $appPermission1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "78145de6-330d-4800-a6ce-494ff2d33d07","Role" #Read and write Microsoft Intune apps
                $appPermission2 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "2f51be20-0bb4-4fed-bf7b-db946066c75e","Role" #Read Microsoft Intune devices
                $appPermission3 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "58ca0d9a-1575-47e1-a3cb-007ef2e4583b","Role" #Read Microsoft Intune RBAC settings
                $appPermission4 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "5ac13192-7ace-4fcf-b828-1a26f28068ee","Role" #Read and write Microsoft Intune configuration
                $appPermission5 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "98830695-27a2-44f7-8c18-0c3ebc9698f6","Role" #Read Group Members

                #Create the full Permissions Object
                $PermsObject = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
                $PermsObject.ResourceAppId = $MSGraphPrincipal.AppId
                $PermsObject.ResourceAccess = $appPermission1, $appPermission2, $appPermission3, $appPermission4, $appPermission5
                
                New-AzureADApplication -DisplayName $Name -RequiredResourceAccess $PermsObject | Out-Null

                If ($SecretYears -eq "1") {$Enddate = ((Get-Date).AddYears(1))}
                If ($SecretYears -eq "3") {$Enddate = ((Get-Date).AddYears(3))}
                If ($SecretYears -eq "5") {$Enddate = ((Get-Date).AddYears(5))}

                $MyApp = (Get-AzureADApplication -Filter "DisplayName eq '$($Name)'")

                $AppObjectID = ($MyApp).ObjectId
                $AppID = ($MyApp).AppId
                $AppDisplayName = ($MyApp).DisplayName
                $Secret = (New-AzureADApplicationPasswordCredential -ObjectId $AppObjectID -EndDate $Enddate)

                Write-Warning "You've created an app registration called $($AppDisplayName)"
                Write-Warning "The AppID is $($AppID)"
                Write-Warning "Your $($SecretYears) year secret value is: $(($Secret).Value)"
            }
    }
    Catch {
        
        Write-Error $Error[0].exception.message         
    }




