<#
Script to add multiple certificates to the Trusted Root Certificate Authority store

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

#>

# Options
$Path = "C:\Certificates\"
$Filetype = ".pem"

# Read in files and set up counter
$certFile = get-childitem $Path | where {$_.Extension -match $Filetype}
$i = 0

# Import Loop
foreach ($cert in $certFile)
    {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.import($Path + $certfile.Name[$i])
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root","LocalMachine")
        $store.Open("MaxAllowed") 
        $store.Add($cert) 
        $store.Close()
        Write-Host "Certificate" $certfile.Name[$i] "- IMPORTED SUCCESSFULLY!"
        $i++ 
             
    }

Write-Host "--- Sucessfully imported: $i Certificates"

