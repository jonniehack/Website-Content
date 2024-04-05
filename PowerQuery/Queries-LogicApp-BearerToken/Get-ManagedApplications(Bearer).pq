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

// Logic App to handle pagination
    LABody = "{
                ""GraphUrl"":""" & GraphURL & """, 
                ""Bearer"":""" & Bearer & """
            }",
    LogicApp = Json.Document(Web.Contents(#"MSGraphCall", [Headers=[#"Content-Type"="application/json"],Content = Text.ToBinary(LABody)])),
    Value = LogicApp[value],
    #"Converted to Table" = Table.FromList(Value, Splitter.SplitByNothing(), null, null, ExtraValues.Error),

// Formatting
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"@odata.type", "id", "displayName", "description", "publisher", "largeIcon", "createdDateTime", "lastModifiedDateTime", "isFeatured", "privacyInformationUrl", "informationUrl", "owner", "developer", "notes", "uploadState", "publishingState", "isAssigned", "roleScopeTagIds", "dependentAppCount", "supersedingAppCount", "supersededAppCount", "committedContentVersion", "fileName", "size", "installCommandLine", "uninstallCommandLine", "applicableArchitectures", "minimumFreeDiskSpaceInMB", "minimumMemoryInMB", "minimumNumberOfProcessors", "minimumCpuSpeedInMHz", "msiInformation", "setupFilePath", "minimumSupportedWindowsRelease", "displayVersion", "minimumSupportedOperatingSystem", "detectionRules", "requirementRules", "rules", "installExperience", "returnCodes"}, {"@odata.type", "id", "displayName", "description", "publisher", "largeIcon", "createdDateTime", "lastModifiedDateTime", "isFeatured", "privacyInformationUrl", "informationUrl", "owner", "developer", "notes", "uploadState", "publishingState", "isAssigned", "roleScopeTagIds", "dependentAppCount", "supersedingAppCount", "supersededAppCount", "committedContentVersion", "fileName", "size", "installCommandLine", "uninstallCommandLine", "applicableArchitectures", "minimumFreeDiskSpaceInMB", "minimumMemoryInMB", "minimumNumberOfProcessors", "minimumCpuSpeedInMHz", "msiInformation", "setupFilePath", "minimumSupportedWindowsRelease", "displayVersion", "minimumSupportedOperatingSystem", "detectionRules", "requirementRules", "rules", "installExperience", "returnCodes"})
in
    #"Expanded Column1"