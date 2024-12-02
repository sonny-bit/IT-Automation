# Ref: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0058493
## Ref2: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0064484
# Initialize variables here
$software_name = "Zoom"
$URL = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"

# Check if app is already installed
echo "Checking if $software_name is installed..."

if (Test-Path "C:\Program Files\Zoom\bin\Zoom.exe") {
    Write-Host "$software_name is already installed..."
} else {
    Write-Host "$software_name is not installed. Proceeding with installation..."
    
    $ProgressPreference = 'SilentlyContinue'

    # Create tmp folder for downloads
    $tmp_path = "C:\tmp\" + $software_name
    echo $tmp_path
    New-Item -Path "$tmp_path" -ItemType Directory

    # Create Installer Path
    $installer_Path = $tmp_path + "\$software_name.msi"
    echo $installer_Path

    # Download exe file into tmp file
    Invoke-WebRequest -Uri $URL -OutFile $installer_Path

    # Install exe file into computer. Run silently, with no user interface
    $args = "/i $installer_Path /qn"
    msiexec /i $installer_Path /quiet /qn /norestart zConfig="AU2_EnableAutoUpdate=1" zSilentStart=1 /log  install.log 

    $msiProcess = Get-Process | Where-Object { $_.ProcessName -eq "msiexec" } | Sort-Object StartTime -Descending | Select-Object -First 1
    echo $msiProcess
    echo "Installing Zoom..."

    while(!$msiProcess.HasExited) {
        Start-Sleep -Seconds 1
    }

    # Remove directory and installer
    Remove-Item -Path $tmp_path -Force -Recurse

    # Check if it successfully installed
   if (Test-Path "C:\Program Files\Zoom\bin\Zoom.exe") {
      echo "$software_name Installation was successful!"
   } else {
      echo "Error: $software_name did not install successfully"
      exit 1
   }
}
