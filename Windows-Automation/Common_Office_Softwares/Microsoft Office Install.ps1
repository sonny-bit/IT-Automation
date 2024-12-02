# Initialize variables here

$software_name = "MSOffice"
$URL = [Direct Link to OfficeSetup.exe. Please login to your office admin page to obtain this link]

# Check if all 7 MS Office Products are installed
$officePaths = @(
    'C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE',
    'C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE',
    'C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE', 
    'C:\Program Files\Microsoft Office\root\Office16\ONENOTE.EXE'
    #, 'C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE', 
    # 'C:\Program Files\Microsoft OneDrive',
    #'C:\Program Files\Microsoft Office\root\Office16\MSACCESS.EXE',
    #'C:\Program Files\Microsoft Office\root\Office16\MSPUB.EXE',
)

$officeProducts = "Word", "Excel", "PowerPoint", "OneNote" #, "Outlook", "OneDrive", 
    #"Access", "Publisher", "Team"
$index = 0
$appsInstalled = $true

foreach ($path in $officePaths) {
    if (! (Test-Path $path)) {
        $Product = $officeProducts[$index]
        Write-Host "Microsoft $Product is not installed"
        $appsInstalled = $false
    }
    $index += 1
}

# Seperate code to check if Microsoft OnDrive installed
if (! (Get-Package | Where-Object {$_.Name -like "*OneDrive*"}) ) {
    $appsInstalled = $false
    Write-Host "Microsoft OneDrive is not installed"
}

echo "Are all apps installed? $appsInstalled"

# Install MS Office if at least one product is not installed
if ($appsInstalled) {
    Write-Host "$software_name is already installed."
} else {
    Write-Host "Some $software_name products are not installed. Proceeding with installation..."
    
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

    # Remove any traces of Microsoft Teams to ensure this downloads
    Remove-Item -Path "$env:APPDATA\Microsoft\Teams" -Recurse -Force
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Teams" -Recurse -Force
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Office\Teams" -Name "PreventInstallationFromMsi" -Force

    # Install exe file into computer. Run silently, with no user interface
    Start-Process -FilePath $installer_Path -Verb runAs

    echo "$software_name Installation in progress. Continue to next app..."
}