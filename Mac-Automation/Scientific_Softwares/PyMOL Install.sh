#!/bin/bash

# Edit init vars here
software_name="PyMOL"
URL="https://www.pymol.org/"

# Fetch the HTML content from the URL
HTML_CONTENT=$(curl -s $URL)

# Define the pattern to search for .dmg files
DMG_PATTERN='href="([^"]+\.dmg)"'

# Use grep to find the first .dmg link in the HTML content
if [[ $HTML_CONTENT =~ $DMG_PATTERN ]]; then
    DOWNLOAD_LINK=${BASH_REMATCH[1]}  # Capture the matched .dmg link
    echo "DMG file found: $DOWNLOAD_LINK"
else
    echo "No .dmg file found."
    exit 1  # Exit the script if no .dmg link is found
fi

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"
echo $tmp_dir

# Create an env variable for dmg install
dmg_path=$tmp_dir$software_name.dmg
echo $dmg_path

# Check if app is already installed
# .apps are directories, not files (so use -d instead of -f)
if [ ! -d "/Applications/$software_name.app" ]; then 
    
    #Make temp folder for downloads. 
    mkdir $tmp_dir; cd $tmp_dir; 

    # Install 
    curl -L -o $dmg_path $DOWNLOAD_LINK;

    # Mount the .dmg file
    hdiutil attach "$dmg_path"

    # Get the volume name of the .dmg file
    dmg_volume=$(hdiutil info | grep '/Volumes/' | grep 'PyMOL.*' | awk '{print $3}')
    echo $dmg_volume

    # Install the application from the mounted .dmg file
    app_path="$dmg_volume/$software_name.app"
    echo $app_path
    sudo cp -R $app_path /Applications/ & wait $!

    # Unmount the .dmg file
    hdiutil detach "$dmg_volume"

    # Tidy Up
    sudo rm -rf $tmp_dir;

    # Check one last time
    if [ -d "/Applications/$software_name.app" ]; then
        echo "App installed success"
    else
        echo "Failed install..."
        exit 1
    fi
else
    echo "Application is already installed."
fi
