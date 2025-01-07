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
$response1 = Get-JCSystemApp -SystemOS 'Windows'
$response2 = Get-JCSystemApp -SystemOS 'macOS'
#$response | Export-Csv -Path "C:\IT_Apps\JC_Apps.csv" -NoTypeInformation

# Convert to JSON
$responseObj1 = ConvertTo-Json $response1

$add1 = "INSERT INTO JSON_JumpCloud ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'WINDOWS_APPS', '" + $responseObj1 + "')"

# Convert to JSON
$responseObj2 = ConvertTo-Json $response2

$add2 = "INSERT INTO JSON_JumpCloud ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'MAC_APPS', '" + $responseObj2 + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
Add-Data -server $ipAddress -database "IT" -text $add2
