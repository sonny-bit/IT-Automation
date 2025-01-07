# Reference: https://support.crashplan.com/hc/en-us/articles/9056919166605--CrashPlan-API-authentication-methods#01GCHZ4RDRDHREXABDHGJS81Q8
## Instead of API Client, this will use the baasic authentication to obtain a token
## This allows certain APIs, such as RestoreHistory, to work.
## Format: curl -u "username:password" 'https://console.us1.crashplan.com/api/v3/auth/jwt?useBody=true' 

## Use postman powershell to generate the basic authorization string, you need the clientID and secret

### NOTE: Do not enable SSO on CrashPlan for this user. It will not work properly to obtain the token if enabled.

cd "C:\IT_Apps\CrashPlanScripts"

# Define the username and password for authentication
$username = "[username]"
$password = Get-Content -Path "password.txt"

# Encode the username and password into a Basic Auth string
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("$($username):$($password)")))

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Basic $base64AuthInfo")

$authToken = Invoke-RestMethod 'https://console.us1.crashplan.com/api/v3/auth/jwt?useBody=true' -Method 'GET' -Headers $headers

$authToken.data.v3_user_token | Out-File -FilePath "C:\IT_Apps\CrashPlanScripts\basicToken.txt"
