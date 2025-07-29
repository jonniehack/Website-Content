let

// Application Registration Permissions needed to make this call :  DeviceManagementServiceConfig.Read.All 
//                                                                  DeviceManagementConfiguration.Read.All

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = MSGraphVersion & "/",
    Resource = "deviceManagement/mobileThreatDefenseConnectors/",
    QueryParams = "",
    GraphURL = Endpoint & Version & Resource & QueryParams,    

// Get an Access Token to make Graph Calls (uses Application Registration)
    Bearer = #"Get-BearerToken" (TenantID, AppID, SecretID, Endpoint), 

// Direct Graph call (No pagination)  
    DirectGraphCall = Json.Document(Web.Contents(
        GraphURL, 
        [
            Headers=[#"Content-Type"="application/json", #"Authorization"=Bearer]
        ]
    )),
    value = DirectGraphCall[value],
    #"Converted to Table" = Table.FromList(value, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

// Formatting
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"id", "lastHeartbeatDateTime", "partnerState", "androidMobileApplicationManagementEnabled", "iosMobileApplicationManagementEnabled", "windowsMobileApplicationManagementEnabled", "androidEnabled", "iosEnabled", "windowsEnabled", "macEnabled", "androidDeviceBlockedOnMissingPartnerData", "iosDeviceBlockedOnMissingPartnerData", "windowsDeviceBlockedOnMissingPartnerData", "macDeviceBlockedOnMissingPartnerData", "partnerUnsupportedOsVersionBlocked", "partnerUnresponsivenessThresholdInDays", "allowPartnerToCollectIOSApplicationMetadata", "allowPartnerToCollectIOSPersonalApplicationMetadata", "microsoftDefenderForEndpointAttachEnabled"}, 
{"id", "lastHeartbeatDateTime", "partnerState", "androidMobileApplicationManagementEnabled", "iosMobileApplicationManagementEnabled", "windowsMobileApplicationManagementEnabled", "androidEnabled", "iosEnabled", "windowsEnabled", "macEnabled", "androidDeviceBlockedOnMissingPartnerData", "iosDeviceBlockedOnMissingPartnerData", "windowsDeviceBlockedOnMissingPartnerData", "macDeviceBlockedOnMissingPartnerData", "partnerUnsupportedOsVersionBlocked", "partnerUnresponsivenessThresholdInDays", "allowPartnerToCollectIOSApplicationMetadata", "allowPartnerToCollectIOSPersonalApplicationMetadata", "microsoftDefenderForEndpointAttachEnabled"})
in
    #"Expanded Column1"