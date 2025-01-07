. "C:\IT_Apps\Add_Data.ps1"
# API Reference: https://falcon.us-2.crowdstrike.com/documentation/page/a2a7fc0e/crowdstrike-oauth2-based-apis

# Prepare function for API call
$RunTime = Get-Date

# init
$JSONtable = "JSON_Crowdstrike"
$dataset = "CS_VULNERABILITIES_DETAILS"

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

#---Call Vulnerability ID API---#
# Modify Headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $authToken")

# Define an array to store responses
$data = @()

# Calculate the date for the last 7 days
$startDate = (Get-Date).AddDays(-7).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$limit = 400

# Construct the API URL with the calculated start date
$apiUrl = "https://api.us-2.crowdstrike.com/spotlight/queries/vulnerabilities/v1?limit=$limit&filter=updated_timestamp%3A%3E'$startDate'"

# Invoke the REST API
$response = $null
$response = Invoke-RestMethod $apiUrl -Method 'GET' -Headers $headers
$data += $response.resources

# Exit code after 15 minutes to ensure 'while' loop does not run infinitely
$EndTime = $RunTime.AddMinutes(15)

# Continue to call Vulnerability API due to limit of 5000
while ((Get-Date) -lt $EndTime) {
    $after = $response.meta.pagination.after
    if ($after -eq '') {
        break
    }

    # Add after parameter
    $apiUrl = "https://api.us-2.crowdstrike.com/spotlight/queries/vulnerabilities/v1?after=$after&limit=$limit&filter=updated_timestamp%3A%3E'$startDate'"

    # Invoke the REST API again
    $response = $null
    $response = Invoke-RestMethod $apiUrl -Method 'GET' -Headers $headers
    $data += $response.resources
}

#---Call API for vulnerability details---#
# Specify the chunk size
$chunkSize = 400

# Define an array to store responses
$resources = @()

# Loop through the data and process in chunks
for ($i = 0; $i -lt $data.Count; $i += $chunkSize) {
    # Get a chunk of data
    $chunk = $data[$i..($i + $chunkSize - 1)]
    
    # Output the count for the current chunk
    #Write-Host "Chunk $($i / $chunkSize + 1): $($chunk.Count) items"

    # Initialize the URL filter
    $urlFilter = ""

    # Loop through the $test array and extract the 'id' property
    foreach ($id in $chunk) {
        $urlFilter += "ids=$id&"
    }

    # Remove the trailing "&" if there are items in the filter
    if ($urlFilter.Length -gt 0) {
        $urlFilter = $urlFilter.TrimEnd('&')
    }

    # Create the apiURL
    $apiUrl = ""
    $apiUrl = "https://api.us-2.crowdstrike.com/spotlight/entities/vulnerabilities/v2?" + $urlFilter
    
    $response = Invoke-RestMethod $apiUrl -Method 'GET' -Headers $headers
    $resources += $response.resources
    
}

#---Push to SQL Server---#
$responseObj = $resources | ConvertTo-Json -Depth 100
$add1 = "INSERT INTO $($JSONtable) ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', '$($dataset)', '" + $responseObj + "')"

Add-Data -server $ipAddress -database "IT" -text $add1
