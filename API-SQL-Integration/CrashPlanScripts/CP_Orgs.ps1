. "C:\IT_Apps\Add_Data.ps1"
$RunTime = Get-Date

# Retrieve OAuth Token
$OAuthScript = "C:\IT_Apps\CrashPlanScripts\CrashPlan OAuth.ps1"
. $OAuthScript
$authToken = Get-Content -Path "C:\IT_Apps\CrashPlanScripts\authToken.txt"

# Call API
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $authToken")

$response = Invoke-RestMethod 'https://console.us1.crashplan.com/api/v1/Org' -ContentType "application/json" -Method 'GET' -Headers $headers

if ($response.data.orgs -eq $null) {
    Write-Output "No data detected. Exiting..."
    exit 1
}


# Convert to JSON
$responseObj = ConvertTo-Json $response.data.orgs

$add1 = "INSERT INTO JSON_CrashPlan ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'ORGS', '" + $responseObj + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
