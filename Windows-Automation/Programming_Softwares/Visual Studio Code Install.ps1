# Variables
$software_name = "Visual_Studio_Code"
$downloadUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64"
$installerPath = "C:\tmp\VSCodeSetup.exe"

# Install without displaying progress. This makes installing faster
$ProgressPreference = 'SilentlyContinue'

if (Get-Package "*Visual Studio Code*") {
    Write-Host "$software_name is already installed."
} else {
    # Download Visual Studio Code installer
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

    # Install Visual Studio Code silently
    Start-Process -FilePath $installerPath -ArgumentList "/VERYSILENT /MERGETASKS=!runcode" -Wait

    # Clean up: Remove the installer if desired
    Remove-Item -Path $installerPath

    Write-Host "$software_name has been successfully installed."
}
