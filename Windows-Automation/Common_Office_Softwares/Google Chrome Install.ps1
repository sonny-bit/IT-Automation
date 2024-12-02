# Variables
$software_name = "Google Chrome"

# Please install the Google Chrome msi package in a shared folder or NAS
$sharePath = "[path to pkg installer]"  # Network share path
$localPath = "C:\tmp\$software_name"  # Local directory to copy files to
$username = "[username to shared folder or NAS]"
$credentialFile = "[password to shared folder or NAS]"  # Path to a file containing the credentials

# Check if app is already installed
echo "Checking if $software_name is installed..."

$chromeRegistryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe"

if (Get-Package "*$software_name*") {
    Write-Host "$software_name is already installed."
} elseif (Test-Path $chromeRegistryPath) {
    Write-Host "Google Chrome is installed."
} else {
    Write-Host "$software_name is not installed. Proceeding with installation..."

    # Read the credential file
    $credentials = Get-Content $credentialFile | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($username, $credentials)

    # Create local folder if it doesn't exist
    if (-not (Test-Path -Path $localPath)) {
        New-Item -ItemType Directory -Path $localPath
    }

    # Find an available drive letter
    $usedDrives = (Get-PSDrive -PSProvider FileSystem).Name
    $availableDrives = "Z Y X W V U T S R Q P O N M L K J I H G F E D C B".Split(" ") | Where-Object { $_ -notin $usedDrives }
    $driveLetter = $availableDrives[0]

    if (-not $driveLetter) {
        Write-Host "No available drive letters."
        exit 1
    }

    # Map the network share
    New-PSDrive -Name $driveLetter -PSProvider FileSystem -Root $sharePath -Credential $credential

    # Check if the drive was successfully mapped
    if (Test-Path "$driveLetter`:") {
        # Copy files from the network share
        Copy-Item -Path "$driveLetter`:\*" -Destination $localPath -Recurse -Force
        Write-Host "Files copied successfully to $localPath"

        # Remove the mapped network drive
        Remove-PSDrive -Name $driveLetter
    } else {
        Write-Host "Failed to map network drive."
        exit 1
    }

    # Dynamically find the MSI file
    $installer_Path = Get-ChildItem -Path $localPath -Filter "*.msi" | Select-Object -First 1

    # Check if the MSI file exists
    if (-not (Test-Path $installer_Path.FullName)) {
        Write-Host "MSI file not found."
        exit 1
    }

    # Install exe file into computer
    $args = "/i `"$($installer_Path.FullName)`" /qn"
    
    # Start the installation process
    $msiProcess = Start-Process msiexec.exe -ArgumentList $args -PassThru

    Write-Host "Installing Google Chrome..."

    # Wait for the installation process to exit
    while (!$msiProcess.HasExited) {
        Start-Sleep -Seconds 1
    }

    Write-Host "$software_name Installation has been completed!"

    # Remove directory and installer
    Remove-Item -Path $localPath -Force -Recurse
}