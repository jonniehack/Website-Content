let
    Source = (TenantID as text, AppID as text, SecretID as text, Resource as text) => let

        // Get an Access Token to make Graph Calls (uses Application Registration)
        ClientId = Text.Combine({"client_id",AppID}, "="),
        ClientSecret = Text.Combine({"client_secret", Uri.EscapeDataString(SecretID)}, "="),
        GrantType = Text.Combine({"grant_type", "client_credentials"}, "="),
        Resource = Text.Combine({"resource", Resource}, "="),
        
        Body = Text.Combine({Resource, ClientId, ClientSecret, GrantType}, "&"),
    
        AuthResponse = Json.Document(Web.Contents(
               "https://login.microsoftonline.com/",
            [
                RelativePath = Text.Combine({TenantID,"/oauth2/token"}),
                Content=Text.ToBinary(Body)
            ]
        )),
    
        AccessToken= AuthResponse[access_token],
        Bearer = Text.Combine({"Bearer", AccessToken}, " ")
    in
        Bearer
in
    Source