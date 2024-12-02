# Note: Install may take 5 minutes
# Variables
$software_name = "TableauDesktop"
$downloadUrl = "https://www.tableau.com/downloads/desktop/reg-pc64"
$installerPath = "C:\tmp\$software_name.exe"

# Install without displaying progress. This makes installing faster
$ProgressPreference = 'SilentlyContinue'

if (Get-Package "Tableau*") {
    Write-Host "$software_name is already installed."
} else {
    # Download TableauDesktop installer
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

    # Install TableauDesktop silently
    Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart", "ACCEPTEULA=1" -Wait

    # Uncomment the line below if you prefer using msiexec
    # msiexec /i $installerPath /quiet

    # Clean up: Remove the installer if desired
    Remove-Item -Path $installerPath

    Write-Host "$software_name has been successfully installed."
}
