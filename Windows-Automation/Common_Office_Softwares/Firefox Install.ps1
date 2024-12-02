# Ref: https://support.mozilla.org/en-US/kb/update-firefox-latest-release

# Only update firefox if it is already installed.
if (Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe") {
    # Specify the path to save the installer
    $installerPath = "C:\tmp\firefox_installer.exe"

    # Download the latest Firefox installer
    Write-Host "Downloading the latest Firefox installer..."
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US" -OutFile $installerPath

    # Check if the download was successful
    if ($? -eq $true) {
        Write-Host "Firefox installer downloaded successfully."

        # Close Firefox if it's running
        Write-Host "Closing Firefox..."
        $Command = {
            Stop-Process -Name "firefox" -ErrorAction SilentlyContinue
        }

        invoke-ascurrentuser -scriptblock $Command

        # Run the installer
        Write-Host "Running the Firefox installer..."
        Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait

        # Cleanup downloaded files
        Write-Host "Cleaning up..."
        Remove-Item -Path $installerPath

        Write-Host "Firefox installation and update process completed."
    } else {
        Write-Host "Failed to download Firefox installer. Please check your internet connection."
    }
} else {
    Write-Host "Firefox x64 is not installed. Will not update or reinstall."
}
