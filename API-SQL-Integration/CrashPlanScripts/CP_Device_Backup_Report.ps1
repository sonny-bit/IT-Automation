. "C:\IT_Apps\Add_Data.ps1"
$RunTime = Get-Date

# Retrieve OAuth Token
$OAuthScript = "C:\IT_Apps\CrashPlanScripts\CrashPlan OAuth.ps1"
. $OAuthScript
$authToken = Get-Content -Path "C:\IT_Apps\CrashPlanScripts\authToken.txt"

# Call API
$pgSize = 1000
$pgNum = 1
$params = @{
    pgSize = $pgSize
    pgNum  = $pgNum
}

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $authToken")

$response = Invoke-RestMethod 'https://console.us1.crashplan.com/api/v1/DeviceBackupReport' -ContentType "application/json" -Method 'GET' -Headers $headers -Body $params

if ($response.data -eq $null) {
    Write-Output "No data detected. Exiting..."
    exit 1
}


# Convert to JSON
$responseObj = ConvertTo-Json $response.data

$add1 = "INSERT INTO JSON_CrashPlan ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'DeviceBackupReport', '" + $responseObj + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
