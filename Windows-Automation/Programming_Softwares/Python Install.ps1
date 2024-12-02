#Note: If you previously had Python installed, you will have to run this command twice
# The 1st time will uninstall any remaining python files and cleanup any corrupted files
# The 2nd install does a fully new install

# Initialize variables here
$software_name = "Python"

# Check if app is already installed
echo "Checking if $software_name is installed..."
# Define the base path for Python installations
$basePath = "C:\Program Files"
# Search for directories starting with "Python" in the base path
$pythonDir = Get-ChildItem -Path $basePath -Directory -Filter "Python*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pythonDir) {
    # Check if python.exe exists in the Python directory
    $pythonExe = Join-Path $pythonDir.FullName "python.exe"

    if (Test-Path $pythonExe) {
        Write-Output "Python executable found: $pythonExe"
        exit
    } else {
        Write-Output "python.exe not found in $($pythonDir.FullName)"
    }
} else {
    Write-Host "$software_name is not installed. Proceeding with installation..."

    #----Get the latest version
    # Define the URL
    $url = "https://www.python.org/downloads/windows/"
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

    # Create Installer Path
    $installer_Path = $tmp_path + "\$software_name.exe"
    echo $installer_Path

    $ProgressPreference = 'SilentlyContinue'

    # Download exe file into tmp file
    Invoke-WebRequest -Uri $downloadLink -OutFile $installer_Path

    # Install exe file into computer. Run silently, with no user interface
    echo "Installation in progress..."
    $log_File_Path = "$tmp_path\PythonInstall.log"
    $args = "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0 /log $log_File_Path"
    Start-Process -FilePath $installer_Path -ArgumentList $args -Wait

    # Remove directory and installer
    Remove-Item -Path $tmp_path -Force -Recurse
}

# Search for directories starting with "Python" in the base path
$pythonDir = Get-ChildItem -Path $basePath -Directory -Filter "Python*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pythonDir) {
    # Check if python.exe exists in the Python directory
    $pythonExe = Join-Path $pythonDir.FullName "python.exe"

    if (Test-Path $pythonExe) {
        Write-Output "Python executable found: $pythonExe"
    } else {
        Write-Output "python.exe not found in $($pythonDir.FullName)... Install unsuccessful."
        exit 1
    }
} else {
    Write-Output "Unsuccessful install..."
    exit 1
}
