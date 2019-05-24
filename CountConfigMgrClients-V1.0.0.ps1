<#
Script to count ConfigMgr clients on domains 

Author:  Jonathan of www.deploymentshare.com
Version: 1.0.0

#>


#Import CSV
$CSV = Import-Csv .\MercuryCloudDCs.csv

#Set Everything to Zero
$Count = 0
$GrandTotal = 0

ForEach ($Entry in $CSV){
    
    # Set Username & password
    $Username = $CSV.Username[$Count]
    $Password = ConvertTo-SecureString $CSV.Password[$Count] -AsPlainText -Force
    $Credential = New-Object -typename System.Management.Automation.PSCredential $Username, $Password
    
    #Invoke commands on remote DC
    $ClientCount = Invoke-Command -ComputerName $CSV.DC[$Count] -Credential $Credential -ScriptBlock {Import-Module activedirectory ; (Get-ADComputer -Filter * | Measure-Object).count} # Close Invoke-Command
    $DomainName = Invoke-Command -ComputerName $CSV.DC[$Count] -Credential $Credential -ScriptBlock {Import-Module activedirectory ; (Get-ADDomain).Dnsroot} # Close Invoke-Command
    Write-Host "$DomainName contains $ClientCount computers" 
    
    # Set Grand Total
    $GrandTotal = $GrandTotal + $ClientCount
    
    #Increment Counter
    $Count ++
                            
        } # Close ForEach

Write-Host -ForegroundColor Green "GRAND TOTAL SCCM CLIENTS  = $GrandTotal"