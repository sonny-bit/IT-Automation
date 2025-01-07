. "C:\IT_Apps\Add_Data.ps1"
# API Reference: https://falcon.us-2.crowdstrike.com/documentation/page/a2a7fc0e/crowdstrike-oauth2-based-apis

# Prepare function for API call
$RunTime = Get-Date

# init
$JSONtable = "JSON_Crowdstrike"
$dataset = "CS_VULNERABILITIES_REMEDIATIONS"

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

#---Call Vulnerability API---#
# Modify Headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $authToken")

# Define an array to store responses
$remediationIDs = @()

# Calculate the date for the last 7 days
$startDate = (Get-Date).AddDays(-7).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$limit = 5000

# Construct the API URL with the calculated start date
$apiUrl = "https://api.us-2.crowdstrike.com/spotlight/combined/vulnerabilities/v1?limit=$limit&filter=updated_timestamp%3A%3E'$startDate'"

# Invoke the REST API
$response = $null
$response = Invoke-RestMethod $apiUrl -Method 'GET' -Headers $headers
$remediationIDs += $response.resources.apps.remediation.ids

# Exit code after 15 minutes to ensure 'while' loop does not run infinitely
$EndTime = $RunTime.AddMinutes(15)

# Continue to call Vulnerability API due to limit of 5000
while ((Get-Date) -lt $EndTime) {
    $after = $response.meta.pagination.after
    if ($after -eq '') {
        break
    }

    # Add after parameter
    $apiUrl = "https://api.us-2.crowdstrike.com/spotlight/combined/vulnerabilities/v1?after=$after&limit=$limit&filter=updated_timestamp%3A%3E'$startDate'"

    # Invoke the REST API again
    $response = $null
    $response = Invoke-RestMethod $apiUrl -Method 'GET' -Headers $headers
    $remediationIDs += $response.resources.apps.remediation.ids
}

# Keep only distinct remediation IDs
$distinctRemediationIDs = $remediationIDs | Select-Object -Unique

# Create URL filer for remediationIDs
# Loop through the $test array and extract the 'id' property
$urlFilter = ""
foreach ($id in $distinctRemediationIDs) {
    $urlFilter += "ids=$id&"
}

# Remove the trailing "&" if there are items in the filter
if ($urlFilter.Length -gt 0) {
    $urlFilter = $urlFilter.TrimEnd('&')
}

# Call remediation API, using remediationIDs as parameters for the URL
$apiUrl = ""
$apiUrl = "https://api.us-2.crowdstrike.com/spotlight/entities/remediations/v2?" + $urlFilter

$response = Invoke-RestMethod $apiUrl -Method 'GET' -Headers $headers

#---Push to SQL Server---#
$responseObj = $response.resources | ConvertTo-Json -Depth 100

$add1 = "INSERT INTO $($JSONtable) ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', '$($dataset)', '" + $responseObj + "')"

Add-Data -server $ipAddress -database "IT" -text $add1
