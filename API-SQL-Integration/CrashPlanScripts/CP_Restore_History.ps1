. "C:\IT_Apps\Add_Data.ps1"
$RunTime = Get-Date

# Retrieve OAuth Token
$OAuthScript = "C:\IT_Apps\CrashPlanScripts\CrashPlan Basic Token.ps1"
. $OAuthScript
$authToken = Get-Content -Path "C:\IT_Apps\CrashPlanScripts\basicToken.txt"

# Call API
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $authToken")

# Get list of orgId to call RestoreHistory
$response = Invoke-RestMethod 'https://console.us1.crashplan.com/api/v1/Org' -ContentType "application/json" -Method 'GET' -Headers $headers
$orgIds = $response.data.orgs.orgId

# Create an ArrayList to store the results
$results = New-Object System.Collections.ArrayList

# Loop through the URLs
foreach ($orgId in $orgIds) {
    #Write-Host "Current orgId is: $orgId"
    $url = "https://console.us1.crashplan.com/api/v1/RestoreHistory?days=30&orgId=$orgId"
    $response = Invoke-RestMethod $url -ContentType "application/json" -Method 'GET' -Headers $headers
    if ($response.data.restoreEvents) {
        # Add each item from the restoreEvents array to $results
        $results.AddRange($response.data.restoreEvents)
    }
}

# Check if $results is empty
if ($results.Count -eq 0) {
    Write-Output "No data detected. Exiting..."
    exit 1
}

# Convert the combined array to JSON
$responseObj = $results | ConvertTo-Json

$add1 = "INSERT INTO JSON_CrashPlan ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'RESTORE_HISTORY', '" + $responseObj + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
