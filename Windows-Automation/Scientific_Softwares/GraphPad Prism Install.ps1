# Initialize variables here
$software_name = "Prism"
# Get the latest version
$url = "https://cdn.graphpad.com/downloads/prism/10/InstallPrism10.msi"


# Check if app is already installed
echo "Checking if $software_name is installed..."

if (Get-Package "*$software_name*") {
    Write-Host "$software_name is already installed."
} else {
    Write-Host "$software_name is not installed. Proceeding with installation..."
    
    # Create tmp folder for downloads
    $tmp_path = "C:\tmp\" + $software_name
    echo $tmp_path
    New-Item -Path "$tmp_path" -ItemType Directory

    # Create Installer Path
    $installer_Path = $tmp_path + "\$software_name.msi"
    echo $installer_Path

    $ProgressPreference = 'SilentlyContinue'

    # Download exe file into tmp file
    Invoke-WebRequest -Uri $url -OutFile $installer_Path

    # Install exe file into computer. Run silently, with no user interface
    $args = "/i $installer_Path /qn"
    Start-Process msiexec.exe -ArgumentList $args -Wait

    # Remove directory and installer
    Remove-Item -Path $tmp_path -Force -Recurse

    if (Get-Package "*$software_name*") {
        Write-Host "$software_name Installation has been completed!"
    } else {
        Write-Host "$software_name Installation failed..."
        $exitCode = 1  # Set exit code to 1 for failure
    }
}

if($exitCode) {
    exit $exitCode
}
