. "C:\IT_Apps\Add_Data.ps1"
$RunTime = Get-Date

# Assuming you have the ImportExcel and JumpCloud modules installed
# If not, install them with: Install-Module ImportExcel, Install-Module JumpCloud

# Authenticate with JumpCloud using the API key
$api_path = "C:\IT_Apps\JumpCloudScript\API Key.txt"
try {
    $apiKey= Get-Content -Path $api_path -Raw
}
catch {
    Write-Host "API File not found or unable to open."
}

Connect-JCOnline $apiKey -Force

# Save info
$response = Get-JCPolicy | Get-JCPolicyTargetGroup

# Convert to JSON
$responseObj = ConvertTo-Json $response

$add1 = "INSERT INTO JSON_JumpCloud ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'POLICY_GROUPS', '" + $responseObj + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
