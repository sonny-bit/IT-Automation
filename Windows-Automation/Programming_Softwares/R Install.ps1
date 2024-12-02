# Initialize variables here
$software_name = "R"

# Check if app is already installed
echo "Checking if $software_name is installed..."

if (Get-Package "*R for Windows*") {
    Write-Host "$software_name is already installed."
    exit
} else {
    Write-Host "$software_name is not installed. Proceeding with installation..."

    #---Get the latest version
    # Define the URL
    $url = "https://cran.r-project.org/bin/windows/base/"

    # Download the raw HTML content from the webpage
    $htmlContent = Invoke-RestMethod -Uri $url

    # Use a regular expression to find the first version number that matches the pattern 'R-4.4.1'
    $versionPattern = 'R-(\d+\.\d+\.\d+)'
    if ($htmlContent -match $versionPattern) {
        $version = $matches[0]  # Extract the full version string (e.g., 'R-4.4.1')
        
        # Construct the download link using the extracted version
        $downloadLink = "https://cran.r-project.org/bin/windows/base/$version-win.exe"
    } else {
        Write-Output "No R version found."
        exit 1
    }
    
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
    $args = "/ALLUSERS /S /VERYSILENT /NORESTART"
    Start-Process -FilePath $installer_Path -ArgumentList $args -Wait

    # Remove directory and installer
    Remove-Item -Path $tmp_path -Force -Recurse
}

if (Get-Package "*R for Windows*") {
    Write-Host "$software_name Installation has been completed!"
} else {
    Write-Host "$software_name Installation failed..."
    exit 1
}
