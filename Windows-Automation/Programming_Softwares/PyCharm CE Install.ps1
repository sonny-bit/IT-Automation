# Initialize variables here
$software_name = "PyCharm"

# Get the latest version
$url = "https://www.jetbrains.com/pycharm/download/?section=windows"
$htmlContent = Invoke-RestMethod -Uri $url
$versionPattern = '\b(\d{4}\.\d+\.\d+)\b'
if ($htmlContent -match $versionPattern) {
    $version = $matches[1]
    $downloadLink = "https://download-cdn.jetbrains.com/python/pycharm-community-$version.exe"
} else {
    Write-Output "Version number not found."
    exit 1
}

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
    Invoke-WebRequest -Uri $downloadLink -OutFile $installer_Path

    # Install exe file into computer. Run silently, with no user interface
    echo "Installation in progress..."
    $args = "/ALLUSERS /S"
    Start-Process -FilePath $installer_Path -ArgumentList $args -Wait

    # Remove directory and installer
    Remove-Item -Path $tmp_path -Force -Recurse
}

if (Get-Package "*$software_name*") {
    Write-Host "$software_name Installation has been completed!"
} else {
    Write-Host "$software_name Installation failed..."
    exit 1
}
