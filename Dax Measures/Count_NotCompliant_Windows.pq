Count_NotCompliant_Windows = 
VAR Number =
CALCULATE( 
    DISTINCTCOUNT(
        'deviceManagement/managedDevices/'[id]), 
        AND(
            'deviceManagement/managedDevices/'[complianceState] <> "Compliant",
            'deviceManagement/managedDevices/'[operatingSystem] = "Windows")
    )
    Return
        If(ISBLANK(Number),0,Number)