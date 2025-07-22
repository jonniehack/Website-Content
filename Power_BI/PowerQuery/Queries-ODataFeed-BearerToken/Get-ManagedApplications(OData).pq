let

// Application Registration Permissions needed to make this call : DeviceManagementApps.Read.All

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "beta/",
    Resource = "deviceAppManagement/mobileApps/",
    QueryParams = "",
    GraphURL = Endpoint & Version & Resource & QueryParams,    

// Get an Access Token to make Graph Calls (uses Application Registration)
    Bearer = #"Get-BearerToken" (TenantID, AppID, SecretID, Endpoint), 

//ODataFeed to process Graph Call
    OData = OData.Feed (
        GraphURL,
            [ Authorization = Bearer ],
            [
                ExcludedFromCacheKey = {"Authorization"},
                ODataVersion = 4,
                Implementation = "2.0"
            ]
    )
in
    OData