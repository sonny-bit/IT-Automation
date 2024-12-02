# This product does not support switches to update Dell Dell applications. We will unisntall this and then in the future, install this version: https://www.dell.com/support/home/en-us/drivers/DriversDetails?driverId=0XNVX

# Specify the display name of the Dell SupportAssist application
$displayName = "Dell Update for Windows Universal"

# Get all processes whose names start with "SupportAssist"
$processes = Get-Process | Where-Object { $_.ProcessName -like "$displayName*" }

# Terminate each process found
foreach ($process in $processes) {
    Write-Host "Terminating process $($process.ProcessName) (PID: $($process.Id))"
    $process | Stop-Process -Force
}

# Get UnisntallSTring
$uninstallString = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
    Where-Object { $_.DisplayName -eq $displayName } |
    Select-Object -ExpandProperty UninstallString

# Extract the product code from the uninstall string using regular expressions
if ($uninstallString -match '\{(.*?)\}') {
    $productCode = "{" + $matches[1] + "}"
    Write-Host "Product code for '$displayName': $productCode"
} else {
    Write-Host "Product code not found for '$displayName'."
}

Write-Host "Product Code is: $productCode"

# Start the uninstallation process
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/X $productCode /qn" -PassThru -NoNewWindow -Wait

# Check if the uninstallation was successful
if ($process.ExitCode -eq 0) {
    Write-Host "Uninstallation completed successfully."
} else {
    Write-Host "Failed to uninstall the application. Exit code: $($process.ExitCode)"
}
