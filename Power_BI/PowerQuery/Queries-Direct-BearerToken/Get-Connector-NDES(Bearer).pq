let

// Application Registration Permissions needed to make this call : DeviceManagementConfiguration.Read.All

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "beta/",
    Resource = "deviceManagement/ndesConnectors/",
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

// Formatting
    #"Converted to Table" = Table.FromList(value, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Display Name" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"id", "lastConnectionDateTime", "state", "displayName", "machineName", "enrolledDateTime", "roleScopeTagIds", "connectorVersion"}, {"id", "lastConnectionDateTime", "state", "displayName", "machineName", "enrolledDateTime", "roleScopeTagIds", "connectorVersion"}),
    #"Renamed Connector Version" = Table.RenameColumns(#"Expanded Display Name",{{"displayName", "Display Name"}, {"connectorVersion", "Connector Version"}})
    
in
    #"Renamed Connector Version"