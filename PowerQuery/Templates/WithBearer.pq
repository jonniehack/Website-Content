let

// Application Registration Permissions needed to make this call : >> PERMISSIONS HERE <<

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "beta/",
    Resource = "/",
    QueryParams = "",
    GraphURL = Endpoint & Version & Resource & QueryParams,   

// Get Bearer Token Using Function 
    Bearer = #"Get-BearerToken" (TenantID, AppID, SecretID, Endpoint),

// Logic App to handle pagination
    LABody = "{
                ""GraphUrl"":""" & GraphURL & """, 
                ""Bearer"":""" & Bearer & """
            }",
    LogicApp = Json.Document(Web.Contents(#"MSGraphCall", [Headers=[#"Content-Type"="application/json"],Content = Text.ToBinary(LABody)])),
    Value = LogicApp[value],
    #"Converted to Table" = Table.FromList(Value, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in
    #"Converted to Table"