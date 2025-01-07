. "C:\IT_Apps\Add_Data.ps1"

$RunTime = Get-Date

# Authenticate with JumpCloud using the API key
$api_path = "C:\IT_Apps\JumpCloudScript\API Key.txt"
try {
    $apiKey= Get-Content -Path $api_path -Raw
}
catch {
    Write-Host "API File not found or unable to open."
}

# Prepare API Call
$headers=@{}
$headers.Add("x-api-key", "$apiKey")

$response = $null
$response = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/v2/groups?fields=membershipMethod&limit=100' -Method GET -Headers $headers

# Convert to JSON
$responseObj = $response | ConvertTo-Json

$add1 = "INSERT INTO JSON_JumpCloud ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'ALL_GROUPS', '" + $responseObj + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
