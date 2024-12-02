# Initialize variables here
$software_name = "Spyder"
$URL = "https://github.com/spyder-ide/spyder/releases/latest/download/Spyder_64bit_full.exe"

# Check if app is already installed
echo "Checking if $software_name is installed..."

if (Get-Package "*$software_name*") {
    Write-Host "$software_name is already installed."
    exit
} else {
    Write-Host "$software_name is not installed. Proceeding with installation..."
    
    # Create tmp folder for downloads
    $tmp_path = "C:\tmp\" + $software_name
    echo $tmp_path
    New-Item -Path "$tmp_path" -ItemType Directory

    # Create Installer Path
    $installer_Path = $tmp_path + "\$software_name.exe"
    echo $installer_Path

    $ProgressPreference = 'SilentlyContinue'

    # Download exe file into tmp file
    Invoke-WebRequest -Uri $URL -OutFile $installer_Path

    # Start the timer to see how long installation takes
    $startTime = Get-Date

    # Install exe file into computer. Run silently, with no user interface
    echo "Installation in progress..."
    $args = "/ALLUSERS /S"
    Start-Process -FilePath $installer_Path -ArgumentList $args -Wait

    # Report the elapsed time
    $endTime = Get-Date
    $elapsedTime = New-TimeSpan -Start $startTime -End $endTime
    Write-Output "Total time to download: $($elapsedTime.TotalSeconds) seconds"

    echo "$software_name Installation has been completed!"

    # Remove directory and installer
    Remove-Item -Path $tmp_path -Force -Recurse
}

if (Get-Package "*$software_name*") {
    Write-Host "$software_name Installation has been completed!"
} else {
    Write-Host "$software_name Installation failed..."
    exit 1
}
