Count_Total_Encrypted = 
VAR Number =
CALCULATE( 
    DISTINCTCOUNT(
        'deviceManagement/managedDevices/'[id]),
        'deviceManagement/managedDevices/'[isEncrypted] = "Encrypted"
    )
    Return
        If(ISBLANK(Number),0,Number)