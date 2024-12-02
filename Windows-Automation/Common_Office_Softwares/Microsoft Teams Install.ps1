# Ref: https://learn.microsoft.com/en-us/microsoftteams/new-teams-bulk-install-client

# Get the username from Win32_ComputerSystem and extract just the username part
$username = (Get-WmiObject -Class Win32_ComputerSystem).UserName -replace '.*\\'

# Construct the path to check
$pathToCheck = "C:\Users\$username\AppData\Local\Packages\MSTeams*"

# Check if any directory starting with MSTeams exists
$teamsDirectories = Get-ChildItem -Path $pathToCheck -Directory -ErrorAction SilentlyContinue

# Report if directories were found
if ($teamsDirectories) {
    Write-Host "MS Teams is already installed."
} else {
    # Set installation directory
    $installDir = "C:\tmp\MSTeams"
    $outputFile = Join-Path -Path $installDir -ChildPath "output.txt"

    # Install without displaying progress. This makes installing faster
    $ProgressPreference = 'SilentlyContinue'

    # Clear installDir if it already exists
    if (Test-Path -Path $installDir -PathType Container) {
        Remove-Item -Path $installDir -Force -Recurse
    }

    # Check if installation directory exists, create if not
    if (-not (Test-Path -Path $installDir -PathType Container)) {
        New-Item -ItemType Directory -Path $installDir | Out-Null
    }

    # Download the installer file
    $url = "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409"
    $file = Join-Path -Path $installDir -ChildPath "teamsbootstrapper.exe"
    Invoke-WebRequest -Uri $url -OutFile $file

    # Start the installation process with the -p argument
    $process = Start-Process -FilePath $file -ArgumentList "-p" -PassThru

    & $file -p > $outputFile

    # Wait for the process to complete
    Write-Host "MS Teams installation in progress..."

    Start-Sleep -Seconds 15

    # Capture and display the output
    $output = Get-Content -Path $outputFile
    Write-Host $output

    # Clean up temporary files
    Remove-Item -Path $installDir -Force -Recurse

    # Check if any directory starting with MSTeams exists
    $teamsDirectories = Get-ChildItem -Path $pathToCheck -Directory -ErrorAction SilentlyContinue

    if ($teamsDirectories) {
        Write-Host "MS Teams Installation complete."
    }
    
}
