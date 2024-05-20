let

// Application Registration Permissions needed to make this call : DeviceManagementServiceConfig.Read.All
//                                                               : DeviceManagementConfiguration.Read.All

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "beta/",
    Resource = "deviceManagement/windowsAutopilotDeviceIdentities/",
    QueryParams = "",
    GraphURL = Endpoint & Version & Resource & QueryParams,    

// Get an Access Token to make Graph Calls (uses Application Registration)
    Bearer = #"Get-BearerToken" (TenantID, AppID, SecretID, Endpoint),   

// ODataFeed to process Graph Call
// https://learn.microsoft.com/en-us/powerquery-m/odata-feed
    OData = OData.Feed (
        GraphURL, 
            [ Authorization = Bearer ],
            [
                ExcludedFromCacheKey = {"Authorization"},
                ODataVersion = 4,
                Implementation = "2.0",
                OmitValues = ODataOmitValues.Nulls
            ]
    )

// Formatting

in
    OData