. "C:\IT_Apps\Add_Data.ps1"
$RunTime = Get-Date

# Retrieve OAuth Token
$OAuthScript = "C:\IT_Apps\CrashPlanScripts\CrashPlan OAuth.ps1"
. $OAuthScript
$authToken = Get-Content -Path "C:\IT_Apps\CrashPlanScripts\authToken.txt"

# Call API
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $authToken")

# Gather All Computer IDs
$computerResponse = Invoke-RestMethod 'https://console.us1.crashplan.com/api/v1/Computer' -ContentType "application/json" -Method 'GET' -Headers $headers

# Array to store computer objects
$computerDataArray = @()

# Call API with Computer ID. Use incSettings=1 to list external drives included
$computerResponse.data.computers | ForEach-Object {
    $computerId = $_.computerId

    # Recursively call API for each computerId
    $url = "https://console.us1.crashplan.com/api/v1/Computer/" + $computerId + "?incSettings=1"
    $response = Invoke-RestMethod $url -ContentType "application/json" -Method 'GET' -Headers $headers

    # Gather the list of external drives
    $pathsArray = $response.data.settings.serviceBackupConfig.backupConfig.backupSets.backupSet.backupPaths.pathset.paths.path

    # Save external drives into a string
    $combinedPaths = ($pathsArray | ForEach-Object { $_.'@include' }) -join ', '

    # Create a new object with computer ID and external drives
    $computerObject = New-Object PSObject -Property @{
        ComputerId = $computerId
        ExternalDrives = $combinedPaths
    }

    # Add the object to the array
    $computerDataArray += $computerObject
}

if ($computerDataArray -eq $null -or $computerDataArray.Count -eq 0) {
    Write-Output "No data detected. Exiting..."
    exit 1
}

# Convert to JSON
$responseObj1 = ConvertTo-Json $computerDataArray

$add1 = "INSERT INTO JSON_CrashPlan ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'CP_EXTERNAL_DRIVES', '" + $responseObj1 + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
