. "C:\IT_Apps\Add_Data.ps1"
# API Reference: https://falcon.us-2.crowdstrike.com/documentation/page/a2a7fc0e/crowdstrike-oauth2-based-apis

# Prepare function for API call
$RunTime = Get-Date

# init
$JSONtable = "JSON_Crowdstrike"
$dataset = "CS_HOSTS"

# credentials
$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
$clientID = Get-Content -Path "C:\IT_Apps\CrowdStrikeScript\clientID.txt"
$secret = Get-Content -Path "C:\IT_Apps\CrowdStrikeScript\secret.txt"

#---Get OAuthToken---#
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("accept", "application/json")
$headers.Add("Content-Type", "application/x-www-form-urlencoded")
$body = "client_id=$clientID" + "&client_secret=$secret"

$response = $null
$response = Invoke-RestMethod 'https://api.us-2.crowdstrike.com/oauth2/token' -Method 'POST' -Headers $headers -Body $body
$authToken = $response.access_token

#---Call APIs---#
# Modify Headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $authToken")

# Call Host ID API
$response = $null
$response = Invoke-RestMethod 'https://api.us-2.crowdstrike.com/devices/queries/devices/v1?limit=5000' -ContentType "application/json" -Method GET -Headers $headers
$deviceID = $response.resources

# Call Host Info
$body = @{
    "ids" = $deviceID
} | ConvertTo-Json
$response = $null
$response = Invoke-RestMethod 'https://api.us-2.crowdstrike.com/devices/entities/devices/v2' -ContentType "application/json" -Method 'POST' -Headers $headers -Body $body

if ($response.resources -eq $null) {
    Write-Output "No data detected. Exiting..."
    exit 1
}

#---Push to SQL SErver---#
$responseObj = $response.resources | ConvertTo-Json -Depth 100

$add1 = "INSERT INTO $($JSONtable) ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', '$($dataset)', '" + $responseObj + "')"

Add-Data -server $ipAddress -database "IT" -text $add1
