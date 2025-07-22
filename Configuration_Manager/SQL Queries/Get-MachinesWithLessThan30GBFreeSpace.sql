USE CM_PR1

SELECT DISTINCT
	LD.SystemName00 as 'Name'
	,PC.Model00 as 'Model'
	,(LD.FreeSpace00 / 1024) as 'Free Space GB'
	,PC.UserName00 as 'Primary User'
	,CH.LastActiveTime as 'Last Logon Timestamp'
FROM
	dbo.Logical_Disk_DATA as LD
	Inner Join dbo.Computer_System_DATA as PC on PC.MachineID = LD.MachineID
	Inner Join dbo.v_CH_ClientHealth as CH on CH.MachineID = LD.MachineID
	Inner Join dbo.v_GS_OPERATING_SYSTEM as OS on OS.ResourceID = LD.MachineID

WHERE
	LD.Caption00 like 'C:'
	and
	LD.FreeSpace00 < 30000

ORDER BY
	CH.LastActiveTime