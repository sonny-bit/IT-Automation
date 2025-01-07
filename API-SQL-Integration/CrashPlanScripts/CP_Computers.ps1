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

$response = Invoke-RestMethod 'https://console.us1.crashplan.com/api/v1/Computer?incAll=1' -ContentType "application/json" -Method 'GET' -Headers $headers -Body $params

if ($response.data.computers -eq $null) {
    Write-Output "No data detected. Exiting..."
    exit 1
}

$computers = $response.data.computers | ForEach-Object {
    $computer = $_
    $_.backupUsage | ForEach-Object {
        $props = $_ | Select-Object -Property selectedFiles, selectedBytes, todoFiles, todoBytes, archiveBytes, billableBytes, sendRateAverage, completionRateAverage, lastBackup, lastCompletedBackup, lastConnected, lastMaintenanceDate, lastCompactDate, modificationDate, creationDate, using, percentComplete, archiveGuid, history, activity
        $props.PSObject.Properties | ForEach-Object {
            Add-Member -InputObject $computer -MemberType NoteProperty -Name ("backupUsage." + $_.Name) -Value $_.Value
        }
    }
    $computer.PSObject.Properties.Remove('backupUsage')
    $computer
}

# Convert to JSON
$responseObj1 = ConvertTo-Json $response.data.computers

$add1 = "INSERT INTO JSON_CrashPlan ( JSON_Date, DATASET, JSON_Data ) VALUES ('" + $RunTime + "', 'COMPUTERS', '" + $responseObj1 + "')"

$ipAddress = Get-Content -Path "C:\IT_Apps\SQL_Server_IP_Address.txt"
Add-Data -server $ipAddress -database "IT" -text $add1
