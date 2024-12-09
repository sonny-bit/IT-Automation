#!/bin/bash
## Reference: https://service.malwarebytes.com/hc/en-us/articles/4413802187411-Add-Mac-endpoints-in-Nebula

# Edit init vars here
software_name="TableauDesktop"
URL="https://www.tableau.com/downloads/desktop/reg-mac"

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"
echo $tmp_dir

# Create an env variable for pkg install
dmg_path=$tmp_dir$software_name.dmg
echo $dmg_path

# Check if app is already installed
# .apps are directories, not files (so use -d instead of -f)
if find /Applications -maxdepth 1 -type d -name 'Tableau*' | grep -q '.'; then
    echo "Application is already installed."
else
    # Make temp folder for downloads. 
    mkdir $tmp_dir
    cd $tmp_dir

    # curl and install
    curl -L -o $dmg_path $URL

    # Mount the .dmg file
    hdiutil attach "$dmg_path" -nobrowse

    # Get the volume name of the .dmg file
    dmg_volume=$(hdiutil info | grep '/Volumes/' | grep 'Tableau*' | awk '{print $3}')
    echo $dmg_volume

    # Install the application from the mounted .dmg file
    app_path="$dmg_volume/Tableau.pkg"
    echo $app_path
    sudo installer -pkg $app_path -target /

    # Tidy Up
    sudo rm -rf $tmp_dir;
    
    # Unmount the .dmg file
    echo "Unmounting Disk"
    hdiutil detach "$dmg_volume"

    echo "Installation Complete!"
fi
