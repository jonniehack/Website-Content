let

// Application Registration Permissions needed to make this call : DeviceManagementServiceConfig.Read.All
//                                                               : DeviceManagementConfiguration.Read.All

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "beta/",
    Resource = "deviceManagement/windowsAutopilotDeviceIdentities/",
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

// Output Processing
    #"Converted to Table" = Table.FromList(Value, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"id", "deploymentProfileAssignmentStatus", "deploymentProfileAssignmentDetailedStatus", "deploymentProfileAssignedDateTime", "groupTag", "purchaseOrderIdentifier", "serialNumber", "productKey", "manufacturer", "model", "enrollmentState", "lastContactedDateTime", "addressableUserName", "userPrincipalName", "resourceName", "skuNumber", "systemFamily", "azureActiveDirectoryDeviceId", "azureAdDeviceId", "managedDeviceId", "displayName", "deviceAccountUpn", "deviceAccountPassword", "deviceFriendlyName", "remediationState", "remediationStateLastModifiedDateTime", "userlessEnrollmentStatus"}, {"id", "deploymentProfileAssignmentStatus", "deploymentProfileAssignmentDetailedStatus", "deploymentProfileAssignedDateTime", "groupTag", "purchaseOrderIdentifier", "serialNumber", "productKey", "manufacturer", "model", "enrollmentState", "lastContactedDateTime", "addressableUserName", "userPrincipalName", "resourceName", "skuNumber", "systemFamily", "azureActiveDirectoryDeviceId", "azureAdDeviceId", "managedDeviceId", "displayName", "deviceAccountUpn", "deviceAccountPassword", "deviceFriendlyName", "remediationState", "remediationStateLastModifiedDateTime", "userlessEnrollmentStatus"})

in
    #"Expanded Column1"