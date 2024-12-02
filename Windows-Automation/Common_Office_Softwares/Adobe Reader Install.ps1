# This script obtains the latest exe version of Adobe

# Initialize variables here
$version = "24.004.20220" # Please insert the latest version here
$software_name = "Adobe Acrobat Reader"
$versionNoDots = $version -replace "\.", ""
$URL = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/$versionNoDots/AcroRdrDC${versionNoDots}_en_US.exe"

# Check if app is already installed
while (!(Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "$software_name*"})) {
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
    $args = "/sAll /rs EULA_ACCEPT=YES"
    Start-Process -FilePath $installer_Path -ArgumentList $args -Wait

    Remove-Item -Path $tmp_path -Force -Recurse

    # Use later to install msi files!
    # msiexec /i myapp.exe /qn

    echo "$software_name Installation has been completed!"
}
