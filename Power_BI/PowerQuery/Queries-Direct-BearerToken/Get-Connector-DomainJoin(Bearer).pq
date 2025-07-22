let

// Application Registration Permissions needed to make this call : 	DeviceManagementConfiguration.Read.All

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "beta/",
    Resource = "deviceManagement/domainJoinConnectors/",
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
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"id", "displayName", "lastConnectionDateTime", "state", "version"}, {"id", "displayName", "lastConnectionDateTime", "state", "version"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Column1",{{"lastConnectionDateTime", type datetime}})
in
    #"Changed Type"