# Initialize variables here
$software_name = "Papers"
$URL = "https://download.readcube.com/app/Papers_Setup.exe"

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
    $installer_Path = $tmp_path + "\$software_name.exe"
    echo $installer_Path

    $ProgressPreference = 'SilentlyContinue'

    # Download exe file into tmp file
    Invoke-WebRequest -Uri $URL -OutFile $installer_Path

    # Install exe file into computer. Run silently, with no user interface
    $args = "/ALLUSERS /S"
    Start-Process -FilePath $installer_Path -ArgumentList $args -Wait

    # Remove directory and installer
    Remove-Item -Path $tmp_path -Force -Recurse

    # Use later to install msi files!
    # msiexec /i myapp.exe /qn

    echo "$software_name Installation has been completed!"
}
