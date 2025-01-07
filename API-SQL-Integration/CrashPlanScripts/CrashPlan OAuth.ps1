#Reference: https://support.crashplan.com/hc/en-us/articles/9056919166605
## Use postman to generate the basic authorization string, you need the clientID and secret

cd C:\IT_Apps\CrashPlanScripts\

$basicAuth = Get-Content -Path "basicAuth.txt" -Raw

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic $basicAuth")

$authToken = Invoke-RestMethod 'https://console.us1.crashplan.com/api/v3/oauth/token?grant_type=client_credentials' -ContentType "application/json" -Method 'POST' -Headers $headers

$authToken.access_token | Out-File -FilePath "C:\IT_Apps\CrashPlanScripts\authToken.txt"
