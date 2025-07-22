Count_NotEncrypted_Windows = 
VAR Number =
CALCULATE( 
    DISTINCTCOUNT(
        'deviceManagement/managedDevices/'[id]), 
        AND(
            'deviceManagement/managedDevices/'[isEncrypted] <> "Encrypted",
            'deviceManagement/managedDevices/'[operatingSystem] = "Windows")
    )
    Return
        If(ISBLANK(Number),0,Number)