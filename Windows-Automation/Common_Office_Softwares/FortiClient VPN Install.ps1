# Initialize variables here
$software_name = "FortiClient"
$URL = "https://filestore.fortinet.com/forticlient/FortiClientVPNOnlineInstaller.exe"
$localPath = "C:\tmp\$software_name"  # Local directory to copy files to

# Check if app is already installed
if ( Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "$software_name*"} ) {
    Write-Host "$software_name is already installed."
} else {
    Write-Host "$software_name is not installed. Proceeding with installation..."
    
    #--- Install FortiClient VPN ---#
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

    echo "$software_name Installation has been completed!"
}