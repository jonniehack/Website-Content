<#
.Synopsis
   Connect to AZ and generate an access Token
.DESCRIPTION
   
.EXAMPLE
   Example of how to use this workflow
.EXAMPLE
   Another example of how to use this workflow
.INPUTS
   Inputs to this workflow (if any)
.OUTPUTS
   Output from this workflow (if any)
.NOTES
   General notes
.FUNCTIONALITY
   The functionality that best describes this workflow
#>

#Parameters
[CmdletBinding()]    
Param 
    (
      [string]$DelegateID = "",
      [Parameter(DontShow = $true)] [string]$global:MsGraphVersion = "beta", 
      [Parameter(DontShow = $true)] [String]$global:MsGraphHost = "graph.microsoft.com",
      [String]$global:GraphURI = "https://$MSGraphHost/$MsGraphVersion",
      [string]$Tenant,
      [string]$ClientID,
      [string]$ClientSecret
    )

#Variables / Constants

###Begin###

#If a ClientID and CLientSecret have been manually specified, those details can be use to authenticate against Azure, so the OAuth request is built
if (($ClientID) -and ($ClientSecret)) {
   Write-Output "Creating OAuth Request from params..."
   
   #Create the body of the Authentication of the request for the OAuth Token
   $Body = @{client_id=$ClientID;client_secret=$ClientSecret;grant_type="client_credentials";scope="https://$MSGraphHost/.default";}
   
   #Get the OAuth Token 
   $OAuthReq = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $Body
   
   #Return access token as a variable
   $OAuthReq.access_token
   }#Close if

#If they are not specified, we first check for the correct AD modules, install them if they are not present and then generate a login form
else {
   Write-Output "Checking for AzureAD module..."

      #Check for Azure Modulse and place the properties in a variable
      $AADMod = Get-Module -Name "AzureAD" -ListAvailable
      $AADModPrev = Get-Module -Name "AzureADPreview" -ListAvailable

      #If the modules are not present, install them
      if (!($AADMod)) 
      {
         Write-Output "AzureAD PowerShell module not found, looking for AzureADPreview"
         if ($AADModPrev) {
            $AADMod = Get-Module -Name "AzureADPreview" -ListAvailable
            } #Nested If
         else {
            try {
                  Write-Output "AzureAD Preview is not installed..."
                  Write-Output "Attempting to Install the AzureAD Powershell module..."
                  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop | Out-Null
                  Install-Module AzureAD -Force -ErrorAction Stop
               }#Try
            catch {
                  Throw "Failed to install the AzureAD PowerShell Module" 
               }#Catch
            }#Nested Else
      }#If

      $AADMod = ($AADMod | Select-Object -Unique | Sort-Object)[-1]

      $ADAL = Join-Path $AADMod.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
      $ADALForms = Join-Path $AADMod.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
      [System.Reflection.Assembly]::LoadFrom($ADAL) | Out-Null
      [System.Reflection.Assembly]::LoadFrom($ADALForms) | Out-Null

      $global:UserInfo = Connect-AzureAD -ErrorAction Stop

      # Microsoft Intune PowerShell Enterprise Application ID 
      $MIPEAClientID = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"

      # The redirectURI
      $RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
      #The Authority to connect with (YOur Tenant)
      IF ($Tenant) {
         $TenantID = $Tenant
      } Else {
         $TenantID = $UserInfo.TenantID
      }
      Write-Host -Foregroundcolor Cyan "Connected to Tenant: $TenantID"
      $Auth = "https://login.microsoftonline.com/$TenantID"

      try {
         $AuthContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $Auth
      
         # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
         # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession
         $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
         $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($UserInfo.Account, "OptionalDisplayableId")
         $global:authResult = $AuthContext.AcquireTokenAsync(("https://" + $MSGraphHost),$MIPEAClientID,$RedirectURI,$platformParameters,$userId).Result
         # If the accesstoken is valid then create the authentication header
         if($authResult.AccessToken){
            # Creating header for Authorization token
            $AADAccessToken = $authResult.AccessToken
            return $AADAccessToken
         } else {
            Throw "Authorization Access Token is null, please re-run authentication..."
         }
      }
      catch {
         Write-Host -ForegroundColor Red $_.Exception.Message
         Write-Host -ForegroundColor Red $_.Exception.ItemName
         Throw "There was an exception while running this module"
      }
   }#Close else


