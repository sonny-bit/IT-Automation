# For Slack, you will have to run the installer as a current logged in user.

# If Nuget is not installed, go ahead and install it
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$PkgProvider = Get-PackageProvider
If ("Nuget" -notin $PkgProvider.Name){
    Install-PackageProvider -Name NuGet -Force
}

# If PSModule RunAsUser is not installed, install it
if ( -not (get-installedModule "RunAsUser" -ErrorAction SilentlyContinue)) {
    install-module RunAsUser -force
}

$Command = {
    # Initialize variables here
    $software_name = "Slack"
    $URL = "https://slack.com/api/desktop.latestRelease?arch=x64&variant=exe&redirect=true"

    if (Get-Package | Where-Object {$_.Name -like "Slack*"}) {
        Write-Host "$software_name is already installed."
    } else {
        Write-Host "$software_name is not installed. Proceeding with installation..."
   
        # Create tmp folder for downloads
        $tmp_root = "C:\tmp"
        $tmp_path = Join-Path $tmp_root $software_name

        if (-not (Test-Path -Path $tmp_root)) {
            New-Item -Path $tmp_root -ItemType Directory
        }

        if (-not (Test-Path -Path $tmp_path)) {
            New-Item -Path $tmp_path -ItemType Directory
        }

        # Install without displaying progress. This makes installing faster
        $ProgressPreference = 'SilentlyContinue'

        # Create Installer Path
        $installer_Path = Join-Path $tmp_path "SlackSetup.exe"
        echo $installer_Path

        # Download exe file into tmp file
        Invoke-WebRequest -Uri $URL -OutFile $installer_Path

        # Install exe file into computer. Run silently, with no user interface
        Start-Process $installer_Path -ArgumentList "/S"

        Start-Sleep -Seconds 60

        echo "Installing $software_name..."
        echo "$software_name Installation has been completed!"
    }
}

invoke-ascurrentuser -scriptblock $Command
