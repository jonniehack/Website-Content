Count_SKU_Pro = 
VAR Number =
CALCULATE( 
    DISTINCTCOUNT(
        'deviceManagement/managedDevices/'[id]), 
        'deviceManagement/managedDevices/'[skuFamily] = "Pro"
    )
    Return
        If(ISBLANK(Number),0,Number)