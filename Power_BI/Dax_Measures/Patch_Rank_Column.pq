Patch Rank = RANKX(
    FILTER(
        'XT - Windows Client Patching Data',
        'XT - Windows Client Patching Data'[Build Number] = 
        EARLIER(
            'XT - Windows Client Patching Data'[Build Number]
            )
        ),  
    'XT - Windows Client Patching Data'[Patch Number])