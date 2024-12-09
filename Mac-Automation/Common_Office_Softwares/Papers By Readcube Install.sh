#!/bin/bash

# Edit init vars here
software_name="Papers"
URL_Intel="https://download.readcube.com/app/Papers_Setup-x64.dmg"
URL_Silicon="https://download.readcube.com/app/Papers_Setup-arm64.dmg"

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

    # Check if system is Intel or Silicon, then curl
    if [ $(uname -m) == "x86_64" ]; then
        curl -L -o $dmg_path $URL_Intel;
    elif [ $(uname -m) == "arm64" ]; then
        curl -L -o $dmg_path $URL_Silicon;
    fi

    # Mount the .dmg file
    hdiutil attach "$dmg_path"

    # Get the volume name of the .dmg file
    dmg_volume=$(hdiutil info | grep '/Volumes/' | grep 'Papers.*' | awk '{print $3}')
    echo $dmg_volume

    # Install the application from the mounted .dmg file
    app_path="$dmg_volume/$software_name.app"
    echo $app_path
    sudo cp -R $app_path /Applications/ & wait $!

    # Unmount the .dmg file
    hdiutil detach "$dmg_volume"

    # Tidy Up
    sudo rm -rf $tmp_dir;

    # Check if app actually installed properly
    if [ ! -d "/Applications/$software_name.app" ]; then
        echo "Error. App did not install correctly..."
        exit 1
    else
        echo "Application installed successfully!"
    fi
else
    echo "Application is already installed."
fi


