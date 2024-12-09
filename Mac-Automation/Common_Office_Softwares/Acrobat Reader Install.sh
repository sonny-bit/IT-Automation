#!/bin/bash

# Edit init vars here
software_name="Adobe"
version="24.004.20219"
versionNoDots="${version//./}"
URL="https://ardownload2.adobe.com/pub/adobe/acrobat/mac/AcrobatDC/${versionNoDots}/AcroRdrSCADC${versionNoDots}_MUI.dmg"

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"

# Create an env variable for dmg install
dmg_path="$tmp_dir$software_name.dmg"

# Check if app is already installed
# .apps are directories, not files (so use -d instead of -f)
if [ ! -d "/Applications/Adobe Acrobat Reader.app" ] || [ ! -d "/Applications/Adobe Acrobat DC.app" ] || [ ! -d "/Applications/Adobe Acrobat DC" ]; then
    
    # Make temp folder for downloads. 
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit

    # Install 
    curl -L -o "$dmg_path" "$URL"

    # Mount the .dmg file without showing it in Finder
    hdiutil attach "$dmg_path" -nobrowse

    # Install the application from the mounted .dmg file
    app_path=$(find /Volumes -type d -name "*Acro*" -exec find {} -type f -name "*.pkg" \; | head -n 1)

    echo "App Path is: $app_path"
    sudo installer -pkg "$app_path" -target /

    # Tidy Up
    sudo rm -rf "$tmp_dir"

    # Check if app actually installed properly
    if [ -d "/Applications/Adobe Acrobat Reader.app" ] || [ -d "/Applications/Adobe Acrobat DC.app" ] || [ -d "/Applications/Adobe Acrobat DC" ]; then
        echo "Application installed successfully!"
    else
        echo "Error. App did not install correctly..."
        exit 1
    fi
else
    echo "Application is already installed."
fi

sleep 5

echo "Unmounting Disk"
# Unmount the .dmg file
hdiutil detach /Volumes/Acro*
