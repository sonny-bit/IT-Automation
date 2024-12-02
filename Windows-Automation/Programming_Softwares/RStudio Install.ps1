# Initialize variables here
$software_name = "RStudio"

# Check if app is already installed
echo "Checking if $software_name is installed..."

$check = Get-Package "*$software_name*" -ErrorAction SilentlyContinue

if ($check) {
    Write-Host "$software_name is already installed."
    exit
} else {
    Write-Host "$software_name is not installed. Proceeding with installation..."

    #---Get latest version
    # Define the URL
    $url = "https://posit.co/download/rstudio-desktop/"

    # Download the raw HTML content from the webpage
    $htmlContent = Invoke-RestMethod -Uri $url

    # Use a regular expression to match the first href that ends with .exe
    $exePattern = 'href="([^"]+\.exe)"'
    if ($htmlContent -match $exePattern) {
        $downloadLink = $matches[1]
    } else {
        Write-Output "No .exe download link found."
        exit 1
    }
    
    # Create tmp folder for downloads
    $tmp_path = "C:\tmp\" + $software_name
    echo $tmp_path
    New-Item -Path "$tmp_path" -ItemType Directory

    # Grab correct file name.
    $fileName = ($downloadLink -split "/")[-1]

    # Create Installer Path
    $installer_Path = $tmp_path + "\$fileName.exe"
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

# Double check
$check = Get-Package "*$software_name*" -ErrorAction SilentlyContinue

if ($check) {
    Write-Host "$software_name successfully installed."
} else {
    Write-Host "$software_name Installation failed..."
    exit 1
}
