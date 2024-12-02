# Initialize variables here
$software_name = "Geneious Prime"
$URL = "https://assets.geneious.com/installers/geneious/release/latest/Geneious_Prime_win64_with_jre.msi"

# Start the timer to see how long installation takes
$startTime = Get-Date

# Check if app is already installed
$softwarePath = "C:\Program Files\$software_name\$software_name.exe"
Test-Path $softwarePath

#This no longer works due to code changes: Get-Package -like "*Geneious Prime"

if (Test-Path $softwarePath) {
    Write-Host "$software_name is already installed."
} else {
    Write-Host "$software_name is not installed. Proceeding with installation..."
    
    # Create tmp folder for downloads
    $tmp_path = "C:\tmp\" + $software_name
    echo $tmp_path
    New-Item -Path "$tmp_path" -ItemType Directory

    $ProgressPreference = 'SilentlyContinue'

    # Create Installer Path
    $installer_Path = $tmp_path + "\$software_name.msi"
    echo $installer_Path

    # Download msi file into tmp file
    Invoke-WebRequest -Uri $URL -OutFile $installer_Path

    # Check if the installer actually installed by checking the file size
    $msiFile = Get-Item -Path $installer_Path
    # Convert the size in bytes to megabytes
    $msiSize = [Math]::Round($msiFile.Length / 1MB, 2)
    # Print the size in megabytes
    Write-Host "Size of $software_name : $msiSize MB"

    # Install msi file into computer. Run silently, with no user interface
    #msiexec /i $installer_Path /qn /passive /norestart
    msiexec.exe /i "$installer_Path" /qn ARPSYSTEMCOMPONENT=0 ARPNOREMOVE=0 /l*v "$tmp_path\$software_name.log"
    #Start-Process msiexec.exe -ArgumentList "/i $installer_Path /quiet /qn /passive /norestart" -Wait
    $msiProcess = Get-Process | Where-Object { $_.ProcessName -eq "msiexec" } | Sort-Object StartTime -Descending | Select-Object -First 1
    echo $msiProcess
    echo "Installing Geneious Prime..."

    while(!$msiProcess.HasExited) {
        Start-Sleep -Seconds 1
    }

    # Report the elapsed time
    $endTime = Get-Date
    $elapsedTime = New-TimeSpan -Start $startTime -End $endTime
    Write-Output "Total time to download: $($elapsedTime.TotalSeconds) seconds"

    echo "$software_name Installation has been completed!"

    # Remove directory and installer
    Remove-Item -Path $tmp_path -Force -Recurse

    # Create a shortcut so the app appears in the Windows searchbar or Start menu
    $shortcutPath = "$([Environment]::GetFolderPath('CommonStartMenu'))\Programs\Geneious Prime.lnk"
    $executablePath = "$env:ProgramFiles\Geneious Prime\Geneious Prime.exe"

    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $executablePath
    $Shortcut.Save()

    if (Test-Path $softwarePath) {
        Write-Host "$software_name Installation has been completed!"
    } else {
        Write-Host "$software_name Installation failed..."
        $exitCode = 1  # Set exit code to 1 for failure
    }
}

if($exitCode) {
    exit $exitCode
}
