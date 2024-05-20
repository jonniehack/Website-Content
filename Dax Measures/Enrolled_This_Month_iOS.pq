Enrolled_This_Month_iOS = 
VAR PreviousMonthEndDate = EOMONTH(TODAY(), -1)
VAR EnrolledCount = 
    CALCULATE(
        COUNTROWS('deviceManagement/managedDevices/'),
        FILTER(
            'deviceManagement/managedDevices/',
            AND(
                'deviceManagement/managedDevices/'[enrolledDateTime] >= PreviousMonthEndDate,
                'deviceManagement/managedDevices/'[operatingSystem] = "iOS"
            )
        )
    )
RETURN
    IF(ISBLANK(EnrolledCount), 0, EnrolledCount)