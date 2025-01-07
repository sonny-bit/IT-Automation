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

Connect-JCOnline $apiKey -Force

# Fetch all user groups
$userGroups = Get-JCGroup -Type User

# Initialize an array to store custom responses
$customResponses = @()

# Prepare API Call
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("x-api-key", "$apiKey")

# Iterate over each user group
foreach ($group in $userGroups) {
    # Fetch detailed information for each user group
    $response = Invoke-RestMethod "https://console.jumpcloud.com/api/v2/usergroups/$($group.id)" -ContentType "application/json" -Method 'GET' -Headers $headers
    # Ensure attributes and posixGroups exist in the response
    if ($response.attributes.posixGroups) {
        $LDAP_id = $response.attributes.posixGroups.id
        $LDAP_name = $response.attributes.posixGroups.name

        # Create a new custom object with the desired properties
        $customResponse = [PSCustomObject]@{
            id = $response.id
            name = $response.name
            LDAP_id = $LDAP_id
            LDAP_name = $LDAP_name
            # Add any other properties you want to include
        }

        # Append the custom object to the array
        $customResponses += $customResponse
    } 
}

# Convert to JSON
$responseObj = ConvertTo-Json $customResponses

$add1 = "INSERT INTO JSON_JumpCloud ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'User_Groups_LDAP', '" + $responseObj + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
