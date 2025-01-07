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

# Prepare API Call
$headers = @{
    "x-api-key" = "$apiKey"
}

# Create a list of start times for each hour of the past 12 hours
$startTimes = @()
for ($i = 0; $i -lt 12; $i++) {
    $startTimes += (Get-Date).AddHours(-12 + $i).ToString("yyyy-MM-ddTHH:mm:ssZ")
}

# Example of passing variables to Start-Job
$jobs = @()
foreach ($startTime in $startTimes) {
    $jobBody = @"
    {
        "service": ["all"],
        "limit": 10000,
        "start_time": "$startTime"
    }
"@

    # Start the job and pass variables using -ArgumentList
    $jobs += Start-Job -ScriptBlock {
        param($headers, $body)
        Invoke-RestMethod 'https://api.jumpcloud.com/insights/directory/v1/events' -ContentType "application/json" -Method 'POST' -Headers $headers -Body $body
    } -ArgumentList $headers, $jobBody
}


# Collect results from all jobs
$allData = New-Object System.Collections.ArrayList
foreach ($job in $jobs) {
    $job | Wait-Job
    try {
        $allData.AddRange((Receive-Job -Job $job))
    } catch {
        Write-Host "Error in job: $($_.Exception.Message)"
    }
    Remove-Job -Job $job
}

#---Send to Database---#
$responseObj = $allData | ConvertTo-Json -Depth 20

$add1 = "INSERT INTO JSON_JumpCloud ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'DIRECTORY_INSIGHTS', '" + $responseObj + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
