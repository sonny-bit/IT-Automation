#!/bin/bash

# Edit init vars here
software_name="Prism 10"
URL="https://cdn.graphpad.com/downloads/prism/10/InstallPrism10.dmg"

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"
echo $tmp_dir

# Create an env variable for dmg install
dmg_path="$tmp_dir$software_name.dmg"
echo $dmg_path

# Check if app is already installed
# .apps are directories, not files (so use -d instead of -f)
if [ ! -d "/Applications/$software_name.app" ]; then 
    
    #Make temp folder for downloads. 
    mkdir $tmp_dir; cd $tmp_dir; 

    # Install 
    curl -L -o $dmg_path $URL;

    # Mount the .dmg file
    hdiutil attach "$dmg_path"

    # Get the volume name of the .dmg file
    dmg_volume="/Volumes/GraphPad $software_name"
    echo $dmg_volume

    # Install the application from the mounted .dmg file
    app_path="/Volumes/GraphPad $software_name/$software_name.app"
    echo $app_path
    sudo cp -R "$app_path" /Applications/ & wait $!

    # Unmount the .dmg file
    hdiutil detach "$dmg_volume"

    # Tidy Up
    sudo rm -rf $tmp_dir;

    if [ -d "/Applications/$software_name.app" ]; then 
        echo "Successfully Installed"
    else 
        echo "Error: App did not install successfully..."
        exit 1
    fi
else
    echo "Application is already installed."
fi
