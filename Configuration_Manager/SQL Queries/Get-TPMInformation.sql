Use CM_PR1

SELECT  
	PC.Name00 as 'Computer Name'
	,PC.Model00 as 'Model'
	,PC.Manufacturer00 as 'Make'
	,PC.Username00 as'User'
	,TPM.PhysicalPresenceVersionInfo00 as 'TPM Version'
	,'TPM is Owned' = CASE
		WHEN TPM.IsOwned_InitialValue00 = 1 THEN 'Yes'
		ELSE 'No'
		END
	,'TPM is Activated' = CASE
		WHEN TPM.IsActivated_InitialValue00 = 1 THEN 'Yes'
		ELSE 'No'
		END
	,'TPM Ready' = CASE
		WHEN TPMS.IsReady00 = 1 THEN 'Yes'
		ELSE 'No'
		END
	,BIOS.SMBIOSBIOSVersion00 as 'BIOS Version'
	,BIOS.SerialNumber00 as 'Serial Number'
FROM
	dbo.TPM_DATA as TPM
	Inner Join dbo.Computer_System_DATA as PC on TPM.MachineID = PC.MachineID
	Inner Join dbo.TPM_STATUS_DATA as TPMS on TPM.MachineID = TPMS.MachineID
	Inner Join dbo.PC_BIOS_DATA as BIOS on TPM.MachineID = BIOS.MachineID