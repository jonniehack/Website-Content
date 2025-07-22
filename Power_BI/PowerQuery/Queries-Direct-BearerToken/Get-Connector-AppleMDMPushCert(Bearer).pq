let

// Application Registration Permissions needed to make this call : DeviceManagementServiceConfig.ReadWrite.All
//                                                                 DeviceManagementManagedDevices.Read.All

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "beta/",
    Resource = "deviceManagement/applePushNotificationCertificate/",
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
    #"Converted to Table" = Record.ToTable(DirectGraphCall),

// Formatting
    #"Transposed Table" = Table.Transpose(#"Converted to Table"),
    #"Promoted Headers" = Table.PromoteHeaders(#"Transposed Table", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"@odata.context", type text}, {"id", type text}, {"appleIdentifier", type text}, {"topicIdentifier", type text}, {"lastModifiedDateTime", type datetime}, {"expirationDateTime", type datetime}, {"certificateUploadStatus", type any}, {"certificateUploadFailureReason", type any}, {"certificateSerialNumber", type text}, {"certificate", type any}})
in
    #"Changed Type"