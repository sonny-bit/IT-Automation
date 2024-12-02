# Initialize variables here
$software_name = "Coot"

# Check if app is already installed
echo "Checking if $software_name is installed..."

if (Test-Path "C:\WinCoot\wincoot.bat") {
    Write-Host "$software_name is already installed."
} else {
    Write-Host "$software_name is not installed. Proceeding with installation..."

    #--------Get the latest version of the URL
    # Define the URL of the webpage
    $pageUrl = "https://bernhardcl.github.io/coot/wincoot-download.html"

    # Fetch the HTML content of the webpage
    $response = Invoke-WebRequest -Uri $pageUrl

    # Use a regex pattern to find the desired URL
    # This regex looks for the href attribute in the anchor tag with class 'coot-download-href'
    $match = [regex]::Match($response.Content, 'href="(https://github.com/bernhardcl/coot/releases/download/[^"]+)"')

    # Check if a match was found and save the URL to a variable
    if ($match.Success) {
        $URL = $match.Groups[1].Value
        Write-Host "URL found: $URL"
    } else {
        Write-Host "URL not found."
        exit 1
    }

    #-----Being Install
    # Create tmp folder for downloads
    $tmp_path = "C:\tmp\" + $software_name
    echo $tmp_path
    New-Item -Path "$tmp_path" -ItemType Directory

    $ProgressPreference = 'SilentlyContinue'

    # Create Installer Path
    $installer_Path = $tmp_path + "\$software_name.exe"
    echo $installer_Path

    # Download exe file into tmp file
    Invoke-WebRequest -Uri $URL -OutFile $installer_Path

    # Install exe file into computer. Run silently, with no user interface
    $args = "/ALLUSERS /S"
    Start-Process -FilePath $installer_Path -ArgumentList $args -Wait

    # Remove directory and installer
    Remove-Item -Path $tmp_path -Force -Recurse

    if (Test-Path "C:\WinCoot\wincoot.bat") {
        Write-Host "$software_name Installation has been completed!"
    } else {
        Write-Host "$software_name Installation failed..."
        $exitCode = 1  # Set exit code to 1 for failure
    }
}

if($exitCode) {
    exit $exitCode
}
