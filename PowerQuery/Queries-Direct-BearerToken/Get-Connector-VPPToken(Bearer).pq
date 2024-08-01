let

// Application Registration Permissions needed to make this call : DeviceManagementServiceConfig.Read.All

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "beta/",
    Resource = "deviceManagement/depOnboardingSettings/",
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
    value = DirectGraphCall[value]{0},

// Formatting
    #"Converted to Table" = Record.ToTable(value),
    #"Transposed Table" = Table.Transpose(#"Converted to Table"),
    #"Promoted Headers" = Table.PromoteHeaders(#"Transposed Table", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"id", type text}, {"appleIdentifier", type text}, {"tokenExpirationDateTime", type datetime}, {"lastModifiedDateTime", type datetime}, {"lastSuccessfulSyncDateTime", type datetime}, {"lastSyncTriggeredDateTime", type datetime}, {"shareTokenWithSchoolDataSyncService", type logical}, {"lastSyncErrorCode", Int64.Type}, {"tokenType", type text}, {"tokenName", type text}, {"syncedDeviceCount", Int64.Type}, {"dataSharingConsentGranted", type logical}, {"roleScopeTagIds", type any}})
in
    #"Changed Type"