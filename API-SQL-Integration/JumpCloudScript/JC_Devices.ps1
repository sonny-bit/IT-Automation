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
$response = Get-JCSystem

# Convert to JSON
$responseObj = ConvertTo-Json $response

$add1 = "INSERT INTO JSON_JumpCloud ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'DEVICES', '" + $responseObj + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1

#================================================
# Save IPV4 Address Info
$results = $response | ForEach-Object {
    $id = $_.id
    $addresses = $_.networkInterfaces | Where-Object { $_.address -ne $null -and $_.address -ne '' -and $_.address -notlike '127.*' -and $_.family -eq 'IPV4' } | Select-Object -ExpandProperty address | Sort-Object
    [PSCustomObject]@{
        id = $id
        addresses = $addresses -join ' | '
    }
}

# Convert the results to JSON
$jsonResult = $results | ConvertTo-Json

$add2 = "INSERT INTO JSON_JumpCloud ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'DEVICES_IPV4_ADDRESSES', '" + $jsonResult + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add2

#================================================
# Save IPV6 Address Info
$results2 = $response | ForEach-Object {
    $id = $_.id
    $addresses = $_.networkInterfaces | Where-Object { $_.address -ne $null -and $_.address -ne '' -and $_.address -notlike '::1*' -and $_.family -eq 'IPV6' } | Select-Object -ExpandProperty address | Sort-Object
    [PSCustomObject]@{
        id = $id
        addresses = $addresses -join ' | '
    }
}

# Convert the results to JSON
$jsonResult2 = $results2 | ConvertTo-Json

$add3 = "INSERT INTO JSON_JumpCloud ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'DEVICES_IPV6_ADDRESSES', '" + $jsonResult2 + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add3
