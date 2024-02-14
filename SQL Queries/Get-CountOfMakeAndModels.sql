Use YOUR_DB_HERE

SELECT  
	Model00 as 'Model',
	Manufacturer00 as 'Make',
	COUNT (Model00) as 'Count'
FROM
	dbo.Computer_System_DATA
WHERE
  	Manufacturer00 Like 'Dell Inc.' 
	or Manufacturer00 Like 'Hewlett-Packard'
	or Manufacturer00 Like 'HP'
	or Manufacturer00 like 'Lenovo'
GROUP BY 
	Model00, Manufacturer00
ORDER BY
	'Count'