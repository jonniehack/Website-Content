let

// Application Registration Permissions needed to make this call : DeviceManagementManagedDevices.Read.All

// Microsoft Graph URL
    Endpoint = "https://graph.microsoft.com/",
    Version = "beta/",
    Resource = "deviceManagement/managedDevices/",
    QueryParams = "",
    GraphURL = Endpoint & Version & Resource & QueryParams,

// Get Access Bearer Token
    Bearer = #"Get-BearerToken" (TenantID, AppID, SecretID, Endpoint),

// Logic App to handle pagination
    LABody = "{
                ""GraphUrl"":""" & GraphURL & """, 
                ""Bearer"":""" & #"Bearer" & """
            }",
    LogicApp = Json.Document(Web.Contents(#"MSGraphCall", [Headers=[#"Content-Type"="application/json"],Content = Text.ToBinary(LABody)])),
    Value = LogicApp[value],

// Output Processing
    #"Converted to Table" = Table.FromList(Value, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"id", "userId", "deviceName", "ownerType", "managedDeviceOwnerType", "managementState", "enrolledDateTime", "lastSyncDateTime", "chassisType", "operatingSystem", "deviceType", "complianceState", "jailBroken", "managementAgent", "osVersion", "easActivated", "easDeviceId", "easActivationDateTime", "aadRegistered", "azureADRegistered", "deviceEnrollmentType", "lostModeState", "activationLockBypassCode", "emailAddress", "azureActiveDirectoryDeviceId", "azureADDeviceId", "deviceRegistrationState", "deviceCategoryDisplayName", "isSupervised", "exchangeLastSuccessfulSyncDateTime", "exchangeAccessState", "exchangeAccessStateReason", "remoteAssistanceSessionUrl", "remoteAssistanceSessionErrorDetails", "isEncrypted", "userPrincipalName", "model", "manufacturer", "imei", "complianceGracePeriodExpirationDateTime", "serialNumber", "phoneNumber", "androidSecurityPatchLevel", "userDisplayName", "configurationManagerClientEnabledFeatures", "wiFiMacAddress", "deviceHealthAttestationState", "subscriberCarrier", "meid", "totalStorageSpaceInBytes", "freeStorageSpaceInBytes", "managedDeviceName", "partnerReportedThreatState", "retireAfterDateTime", "preferMdmOverGroupPolicyAppliedDateTime", "autopilotEnrolled", "requireUserEnrollmentApproval", "managementCertificateExpirationDate", "iccid", "udid", "roleScopeTagIds", "windowsActiveMalwareCount", "windowsRemediatedMalwareCount", "notes", "configurationManagerClientHealthState", "configurationManagerClientInformation", "ethernetMacAddress", "physicalMemoryInBytes", "processorArchitecture", "specificationVersion", "joinType", "skuFamily", "skuNumber", "managementFeatures", "enrollmentProfileName", "bootstrapTokenEscrowed", "deviceFirmwareConfigurationInterfaceManaged", "hardwareInformation", "deviceActionResults", "usersLoggedOn", "chromeOSDeviceInfo"}, {"id", "userId", "deviceName", "ownerType", "managedDeviceOwnerType", "managementState", "enrolledDateTime", "lastSyncDateTime", "chassisType", "operatingSystem", "deviceType", "complianceState", "jailBroken", "managementAgent", "osVersion", "easActivated", "easDeviceId", "easActivationDateTime", "aadRegistered", "azureADRegistered", "deviceEnrollmentType", "lostModeState", "activationLockBypassCode", "emailAddress", "azureActiveDirectoryDeviceId", "azureADDeviceId", "deviceRegistrationState", "deviceCategoryDisplayName", "isSupervised", "exchangeLastSuccessfulSyncDateTime", "exchangeAccessState", "exchangeAccessStateReason", "remoteAssistanceSessionUrl", "remoteAssistanceSessionErrorDetails", "isEncrypted", "userPrincipalName", "model", "manufacturer", "imei", "complianceGracePeriodExpirationDateTime", "serialNumber", "phoneNumber", "androidSecurityPatchLevel", "userDisplayName", "configurationManagerClientEnabledFeatures", "wiFiMacAddress", "deviceHealthAttestationState", "subscriberCarrier", "meid", "totalStorageSpaceInBytes", "freeStorageSpaceInBytes", "managedDeviceName", "partnerReportedThreatState", "retireAfterDateTime", "preferMdmOverGroupPolicyAppliedDateTime", "autopilotEnrolled", "requireUserEnrollmentApproval", "managementCertificateExpirationDate", "iccid", "udid", "roleScopeTagIds", "windowsActiveMalwareCount", "windowsRemediatedMalwareCount", "notes", "configurationManagerClientHealthState", "configurationManagerClientInformation", "ethernetMacAddress", "physicalMemoryInBytes", "processorArchitecture", "specificationVersion", "joinType", "skuFamily", "skuNumber", "managementFeatures", "enrollmentProfileName", "bootstrapTokenEscrowed", "deviceFirmwareConfigurationInterfaceManaged", "hardwareInformation", "deviceActionResults", "usersLoggedOn", "chromeOSDeviceInfo"}),
    #"Expanded hardwareInformation" = Table.ExpandRecordColumn(#"Expanded Column1", "hardwareInformation", {"serialNumber", "totalStorageSpace", "freeStorageSpace", "imei", "meid", "manufacturer", "model", "phoneNumber", "subscriberCarrier", "cellularTechnology", "wifiMac", "operatingSystemLanguage", "isSupervised", "isEncrypted", "batterySerialNumber", "batteryHealthPercentage", "batteryChargeCycles", "isSharedDevice", "tpmSpecificationVersion", "operatingSystemEdition", "deviceFullQualifiedDomainName", "deviceGuardVirtualizationBasedSecurityHardwareRequirementState", "deviceGuardVirtualizationBasedSecurityState", "deviceGuardLocalSystemAuthorityCredentialGuardState", "osBuildNumber", "operatingSystemProductType", "ipAddressV4", "subnetAddress", "esimIdentifier", "systemManagementBIOSVersion", "tpmManufacturer", "tpmVersion", "sharedDeviceCachedUsers"}, {"serialNumber.1", "totalStorageSpace", "freeStorageSpace", "imei.1", "meid.1", "manufacturer.1", "model.1", "phoneNumber.1", "subscriberCarrier.1", "cellularTechnology", "wifiMac", "operatingSystemLanguage", "isSupervised.1", "isEncrypted.1", "batterySerialNumber", "batteryHealthPercentage", "batteryChargeCycles", "isSharedDevice", "tpmSpecificationVersion", "operatingSystemEdition", "deviceFullQualifiedDomainName", "deviceGuardVirtualizationBasedSecurityHardwareRequirementState", "deviceGuardVirtualizationBasedSecurityState", "deviceGuardLocalSystemAuthorityCredentialGuardState", "osBuildNumber", "operatingSystemProductType", "ipAddressV4", "subnetAddress", "esimIdentifier", "systemManagementBIOSVersion", "tpmManufacturer", "tpmVersion", "sharedDeviceCachedUsers"}),

// Formatting
    #"Removed Columns" = Table.RemoveColumns(#"Expanded hardwareInformation",{"managedDeviceOwnerType"}),
    #"Formatted Date Columns" = Table.TransformColumnTypes(#"Removed Columns",{{"enrolledDateTime", type datetime}, {"lastSyncDateTime", type datetime}, {"easActivationDateTime", type datetime}, {"exchangeLastSuccessfulSyncDateTime", type datetime}, {"complianceGracePeriodExpirationDateTime", type datetime}, {"retireAfterDateTime", type datetime}, {"preferMdmOverGroupPolicyAppliedDateTime", type datetime}, {"managementCertificateExpirationDate", type datetime}}),
    #"Replaced Company" = Table.ReplaceValue(#"Formatted Date Columns","company","Company",Replacer.ReplaceText,{"ownerType"}),
    #"Replaced Personal" = Table.ReplaceValue(#"Replaced Company","personal","Personal",Replacer.ReplaceText,{"ownerType"}),
    #"Replaced Managed" = Table.ReplaceValue(#"Replaced Personal","managed","Managed",Replacer.ReplaceText,{"managementState"}),
    #"Replaced Android" = Table.ReplaceValue(#"Replaced Managed","android","Android",Replacer.ReplaceText,{"deviceType"}),
    #"Replaced Android Enterprise" = Table.ReplaceValue(#"Replaced Android","androidEnterprise","Android Enterprise",Replacer.ReplaceText,{"deviceType"}),
    #"Replaced Windows" = Table.ReplaceValue(#"Replaced Android Enterprise","windowsRT","Windows",Replacer.ReplaceText,{"deviceType"}),
    #"Replaced Compliant" = Table.ReplaceValue(#"Replaced Windows","compliant","Compliant",Replacer.ReplaceText,{"complianceState"}),
    #"Replaced Non-Compliant" = Table.ReplaceValue(#"Replaced Compliant","nonCompliant","Non-Compliant",Replacer.ReplaceText,{"complianceState"}),
    #"Replaced ConfigMgr" = Table.ReplaceValue(#"Replaced Non-Compliant","configManager","Configuration Manager",Replacer.ReplaceText,{"complianceState"}),
    #"Replaced In Grace Period" = Table.ReplaceValue(#"Replaced ConfigMgr","inGracePeriod","In Grace Period",Replacer.ReplaceText,{"complianceState"}),
    #"Replaced Google Cloud DPC" = Table.ReplaceValue(#"Replaced In Grace Period","googleCloudDevicePolicyController","Google Cloud DPC",Replacer.ReplaceText,{"managementAgent"}),
    #"Replaced MDM" = Table.ReplaceValue(#"Replaced Google Cloud DPC","mdm","MDM",Replacer.ReplaceText,{"managementAgent"}),
    #"Replaced Android EDD" = Table.ReplaceValue(#"Replaced MDM","androidEnterpriseDedicatedDevice","Android Enterprise Dedicated Device",Replacer.ReplaceText,{"deviceEnrollmentType"}),
    #"Replaced Android EFM" = Table.ReplaceValue(#"Replaced Android EDD","androidEnterpriseFullyManaged","Android Enterprise Fully Managed",Replacer.ReplaceText,{"deviceEnrollmentType"}),
    #"Replaced User Enrollment" = Table.ReplaceValue(#"Replaced Android EFM","userEnrollment","User Enrollment",Replacer.ReplaceText,{"deviceEnrollmentType"}),
    #"Replaced Co-Management" = Table.ReplaceValue(#"Replaced User Enrollment","windowsCoManagement","Windows Co-Management",Replacer.ReplaceText,{"deviceEnrollmentType"}),
    #"Replaced Samsung" = Table.ReplaceValue(#"Replaced Co-Management","samsung","Samsung",Replacer.ReplaceText,{"manufacturer"}),
    #"Replaced Vodafone UK" = Table.ReplaceValue(#"Replaced Samsung","vodafone UK","Vodafone UK",Replacer.ReplaceText,{"subscriberCarrier"}),
    #"Replaced Registered" = Table.ReplaceValue(#"Replaced Vodafone UK","registered","Registered",Replacer.ReplaceText,{"deviceRegistrationState"}),
    #"Removed Duplicate or Not Needed" = Table.RemoveColumns(#"Replaced Registered",{"serialNumber.1", "imei.1", "meid.1", "manufacturer.1", "model.1", "phoneNumber.1", "subscriberCarrier.1", "isSupervised.1", "isEncrypted.1", "sharedDeviceCachedUsers", "deviceActionResults", "usersLoggedOn", "chromeOSDeviceInfo", "tpmVersion", "tpmManufacturer", "systemManagementBIOSVersion", "esimIdentifier", "subnetAddress", "ipAddressV4", "operatingSystemProductType", "osBuildNumber", "operatingSystemEdition", "tpmSpecificationVersion", "batteryChargeCycles", "batteryHealthPercentage", "deviceFullQualifiedDomainName", "batterySerialNumber", "operatingSystemLanguage", "wifiMac", "cellularTechnology", "freeStorageSpace", "totalStorageSpace", "enrollmentProfileName", "specificationVersion", "processorArchitecture", "physicalMemoryInBytes", "ethernetMacAddress", "notes", "chassisType", "remoteAssistanceSessionUrl", "remoteAssistanceSessionErrorDetails", "partnerReportedThreatState", "iccid", "udid", "managementFeatures", "roleScopeTagIds"}),
    #"Added Patch Number" = Table.AddColumn(#"Removed Duplicate or Not Needed", "Patch Number", each Text.AfterDelimiter([osVersion], ".", 2), type text),
    #"Added Build Number" = Table.AddColumn(#"Added Patch Number", "Build Number", each Text.AfterDelimiter([osVersion], ".", 1), type text),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Build Number",{{"osVersion", type text}}),
    #"Replaced AAD Joined" = Table.ReplaceValue(#"Changed Type","azureADJoined","Azure AD Joined",Replacer.ReplaceText,{"joinType"}),
    #"Replaced AAD Registered" = Table.ReplaceValue(#"Replaced AAD Joined","azureADRegistered","Azure AD Registered",Replacer.ReplaceText,{"joinType"}),
    #"Replaced Hybrid" = Table.ReplaceValue(#"Replaced AAD Registered","hybridAzureADJoined","Hybrid Azure AD Joined",Replacer.ReplaceText,{"joinType"}),
    #"Formatted Space" = Table.TransformColumnTypes(#"Replaced Hybrid",{{"totalStorageSpaceInBytes", Int64.Type}, {"freeStorageSpaceInBytes", Int64.Type}, {"isEncrypted", type text}}),
    #"Replaced Encrypted" = Table.ReplaceValue(#"Formatted Space","true","Encrypted",Replacer.ReplaceText,{"isEncrypted"}),
    #"Replaced Not Encrypted" = Table.ReplaceValue(#"Replaced Encrypted","false","Not Encrypted",Replacer.ReplaceText,{"isEncrypted"}),
    #"Changed Type AP Enrolled" = Table.TransformColumnTypes(#"Replaced Not Encrypted",{{"autopilotEnrolled", type text}}),
    #"Replaced True" = Table.ReplaceValue(#"Changed Type AP Enrolled","true","True",Replacer.ReplaceText,{"autopilotEnrolled"}),
    #"Replaced False" = Table.ReplaceValue(#"Replaced True","false","False",Replacer.ReplaceText,{"autopilotEnrolled"}),
    #"Changed Android Security Patch Level" = Table.TransformColumnTypes(#"Replaced False",{{"androidSecurityPatchLevel", type datetime}}),
    #"Create Android Patch Month" = Table.DuplicateColumn(#"Changed Android Security Patch Level", "androidSecurityPatchLevel", "Android Patch Month"),
    #"Extracted Month Name" = Table.TransformColumns(#"Create Android Patch Month", {{"Android Patch Month", each Date.MonthName(_), type text}}),
    #"Create Android Patch Year" = Table.DuplicateColumn(#"Extracted Month Name", "androidSecurityPatchLevel", "Android Patch Year"),
    #"Extracted Year" = Table.TransformColumns(#"Create Android Patch Year",{{"Android Patch Year", Date.Year, Int64.Type}}),
    #"Replaced Jailbroken Blank Entry" = Table.ReplaceValue(#"Extracted Year","","Unknown",Replacer.ReplaceValue,{"jailBroken"}),
    #"Replaced Android 10.0" = Table.ReplaceValue(#"Replaced Jailbroken Blank Entry","10","10.0",Replacer.ReplaceValue,{"osVersion"}),
    #"Replaced Android 11.0" = Table.ReplaceValue(#"Replaced Android 10.0","11","11.0",Replacer.ReplaceValue,{"osVersion"}),
    #"Replaced Android 12.0" = Table.ReplaceValue(#"Replaced Android 11.0","12","12.0",Replacer.ReplaceValue,{"osVersion"}),
    #"Replaced Android 13.0" = Table.ReplaceValue(#"Replaced Android 12.0","13","13.0",Replacer.ReplaceValue,{"osVersion"}),
    #"Replaced Android 14.0" = Table.ReplaceValue(#"Replaced Android 13.0","14","14.0",Replacer.ReplaceValue,{"osVersion"}),
    #"Replaced Android 15.0" = Table.ReplaceValue(#"Replaced Android 14.0","15","15.0",Replacer.ReplaceValue,{"osVersion"}),
    #"Create Windows Version" = Table.DuplicateColumn(#"Replaced Android 15.0", "osVersion", "Windows Version"),
    #"Create Version" = Table.AddColumn(#"Create Windows Version", "Version", each Text.BeforeDelimiter([Build Number], "."), type text),
    #"Replaced 20H2" = Table.ReplaceValue(#"Create Version","19042","20H2",Replacer.ReplaceText,{"Version"}),
    #"Replaced 21H1" = Table.ReplaceValue(#"Replaced 20H2","19043","21H1",Replacer.ReplaceText,{"Version"}),
    #"Replaced 21H2" = Table.ReplaceValue(#"Replaced 21H1","19044","21H2",Replacer.ReplaceText,{"Version"}),
    #"Replaced 22H2" = Table.ReplaceValue(#"Replaced 21H2","19045","22H2",Replacer.ReplaceText,{"Version"}),
    #"Create Apple Major Version" = Table.AddColumn(#"Replaced 22H2", "Apple Major Version", each Text.BeforeDelimiter([osVersion], "."), type text)
in
    #"Create Apple Major Version"