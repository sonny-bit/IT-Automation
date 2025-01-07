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
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("x-api-key", "$apiKey")

$url = 'https://console.jumpcloud.com/api/v2/systeminsights/chrome_extensions?limit=10000'

$response = Invoke-RestMethod -Uri $url -Method 'GET' -Headers $headers

# Combine the JSON data from both responses into a single array
$responseObj = $response | ConvertTo-Json -Depth 20 

$add1 = "INSERT INTO JSON_JumpCloud ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'JC_CHROME_EXTENSIONS', '" + $responseObj + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
