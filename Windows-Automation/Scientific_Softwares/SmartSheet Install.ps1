# Specify the URL of the installer file
$Url = "https://builds.desktopapp.smartsheet.com/public/win32/Smartsheet-setup.exe"

$installFileName = "Smartsheet-setup.exe"
$appName = "SmartSheet"

# Create tmp directory if it doesn't exist
if (-not (Test-Path -Path "C:\tmp" -PathType Container)) {
    New-Item -Path "C:\tmp" -ItemType Directory
}

# Specify the path to save the downloaded installer
$Path = "C:\tmp\$installFileName"

# Check if already installed
$checkInstalled = Get-Package -ProviderName Programs | Where-Object { $_.Name -eq "SmartSheet" }


if ($checkInstalled) {
    Write-Host "$appName is already installed. Skipping installation."
    exit
} else {
    # Store the original ProgressPreference value
    $originalProgressPreference = $ProgressPreference

    try {
        # Set ProgressPreference to SilentlyContinue
        $ProgressPreference = 'SilentlyContinue'

        # Download the installer
        Invoke-WebRequest -Uri $Url -OutFile $Path

        # Install the installer silently
        Start-Process -Wait -FilePath $Path -ArgumentList '/S /allusers'

        # Clean up the downloaded installer
        Remove-Item -Path $Path -Force
    } finally {
        # Reset ProgressPreference to its original value
        $ProgressPreference = $originalProgressPreference
    }
}

$checkInstalled = Get-Package -ProviderName Programs | Where-Object { $_.Name -eq "SmartSheet" }
if ($checkInstalled) {
    Write-Host "$appName installation completed successfully."
} else {
    Write-Host "$appName installation failed."
    Exit 1  # Return an error exit code
}
