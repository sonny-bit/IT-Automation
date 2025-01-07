. "C:\IT_Apps\Add_Data.ps1"
$domain = "[Your Org's Domain Name].freshdesk.com"

$RunTime = Get-Date
Write-Host "STARTED" 

# Get tickets for only those that have activity from the past week
$DatePassed = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")

# PREPARE API HEADER
######################################################
Write-Host "PREPARE API HEADER" 
######################################################

$api_path = "C:\IT_Apps\FreshDeskScripts\API_Key.txt"
$apiKey = Get-Content -Path $api_path -Raw

# Combine the API key with a dummy password (X)
$plainText = "$($apiKey):X"

# Convert to Base64
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($plainText))

# Create the headers dictionary
$headersBasic = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headersBasic.Add("Authorization", "Basic $base64AuthInfo")
$headersBasic.Add("Content-Type", "application/json")

# GET DATA IN BATCH
######################################################
Write-Host "GET Freshdesk TICKETS - description" 
######################################################
$responseAll = @()
$page = 1

# Loop to fetch multiple pages
do {
    $endpoint = "https://$domain/api/v2/tickets?updated_since=$DatePassed&per_page=100&page=$page&include=description"
    $response = Invoke-RestMethod -Uri $endpoint -Method 'GET' -Headers $headersBasic
    if ($response -ne $null -and $response.Count -gt 0) {
        $responseAll += $response
        $page += 1
    } else {
        break
    }
} while ($true)

# Check if $responseAll.Count is 0 and exit if true
if ($responseAll.Count -eq 0) {
    Write-Output "No tickets detected."
    exit
}

# Remove 'description' and keep 'description_text'. Also handle double quotes in 'description_text'
foreach ($item in $responseAll) {
    $item.PSObject.Properties.Remove("description")
}

Write-Host "CONVERT JSON"
$responseObj = $responseAll | ConvertTo-Json -Depth 10

# INSERT TO SQL
######################################################
Write-Host "INSERT INTO JSON_Freshdesk" 
######################################################
$add1 = "INSERT INTO JSON_Freshdesk ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'Tickets_Description', '" + $responseObj + "')"
$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
