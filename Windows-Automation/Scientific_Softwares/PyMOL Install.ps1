# Initialize variables here
$software_name = "PyMOL"

# Get the latest version
$url = "https://www.pymol.org/"
$htmlContent = Invoke-RestMethod -Uri $url
$exePattern = 'href="([^"]+\.exe)"'
if ($htmlContent -match $exePattern) {
    $downloadLink = $matches[1]  # Capture the matched .exe link
    Write-Output "Executable link found: $downloadLink"
} else {
    Write-Output "No .exe link found."
    exit 1  # Exit the script if no .exe link is found
}

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

    $ProgressPreference = 'SilentlyContinue'

    # Create Installer Path
    $installer_Path = $tmp_path + "\$software_name.exe"
    echo $installer_Path

    # Download exe file into tmp file
    Invoke-WebRequest -Uri $downloadLink -OutFile $installer_Path

    # Install exe file into computer. Run silently, with no user interface
    $args = "/S"
    Start-Process -FilePath $installer_Path -ArgumentList $args -Wait

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
