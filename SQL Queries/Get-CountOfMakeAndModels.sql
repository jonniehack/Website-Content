Use CM_PR1

SELECT  
	Model00 as 'Model',
	Manufacturer00 as 'Make',
	COUNT (Model00) as 'Count'
FROM
	dbo.Computer_System_DATA
WHERE
  	Manufacturer00 Like 'Dell Inc.' or Manufacturer00 Like 'Hewlett-Packard'
GROUP BY 
	Model00, Manufacturer00
ORDER BY
	'Count'