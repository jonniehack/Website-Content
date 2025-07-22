Count_Active_In_Last_30Days = 
VAR DATA = CALCULATE(
    DISTINCTCOUNT('deviceManagement/managedDevices/'[id]),
    DATESINPERIOD(
       'deviceManagement/managedDevices/'[lastSyncDateTime].[Date],
       TODAY(),
       -30
       ,DAY
))
RETURN 
IF(ISBLANK(DATA),0,DATA)