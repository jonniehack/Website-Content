let

// Application Registration Permissions needed to make this call : >> PERMISSIONS HERE <<

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "beta/",
    Resource = "/",
    QueryParams = "",                           
    GraphURL = Endpoint & Version & Resource & QueryParams,

// Logic App to handle pagination
    LABody = "{
                ""GraphUrl"":""" & GraphURL & """, 
                ""TenantID"":""" & TenantID & """,
                ""AppID"":""" & AppID & """,
                ""SecretID"":""" & SecretID & """,
                ""Audience"":""" & Endpoint & """
            }",
    LogicApp = Json.Document(Web.Contents(#"MSGraphCall-NoBearer", [Headers=[#"Content-Type"="application/json"],Content = Text.ToBinary(LABody)])),
    Value = LogicApp[value],
    #"Converted to Table" = Table.FromList(Value, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in
    #"Converted to Table"