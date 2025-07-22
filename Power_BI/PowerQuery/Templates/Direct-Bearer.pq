let

// Application Registration Permissions needed to make this call : 	

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "",
    Resource = "",
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
    value = DirectGraphCall[value]

// Formatting

in
    value