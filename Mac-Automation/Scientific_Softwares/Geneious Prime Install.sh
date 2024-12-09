#!/bin/bash

# Edit init vars here
software_name="Geneious"
URL="https://assets.geneious.com/installers/geneious/release/latest/Geneious_Prime_mac64_with_jre.dmg"

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"
echo $tmp_dir

# Create an env variable for dmg install
dmg_path=$tmp_dir$software_name.dmg
echo $dmg_path

# Check if app is already installed
# .apps are directories, not files (so use -d instead of -f)
if [ ! -d "/Applications/Geneious Prime.app" ]; then 
    
    #Make temp folder for downloads. 
    mkdir $tmp_dir; cd $tmp_dir; 

    # Install 
    curl -L -o $dmg_path $URL;

    # Mount the .dmg file
    hdiutil attach "$dmg_path"

    # Get the volume name of the .dmg file
    dmg_volume1=$(hdiutil info | grep '/Volumes/' | grep 'Geneious.*' | awk '{print $3}')
    dmg_volume2=$(hdiutil info | grep '/Volumes/' | grep 'Geneious.*' | awk '{print $4}')

    # Modify dmg_volume path specifically for Genesis Prime.
    substring='/Volumes/'
    echo $dmg_volume1
    dmg_volume2=${dmg_volume2/$substring}
    echo $dmg_volume2
    
    dmg_volume="$dmg_volume1 $dmg_volume2"
    echo $dmg_volume

    # Install the application from the mounted .dmg file
    app_path="$dmg_volume/Geneious Prime.app/"
    echo $app_path

    # Test for developer side
    if [ "$app_path" = "/Volumes/Geneious Prime_mac64_2023_0_4_with_jre/Geneious Prime.app/" ]; then
        echo "Volume path is probably correct."
    else
        echo "Volume path might be wrong"
    fi

    # This part does not work
    sudo cp -R "$app_path" "/Applications/Geneious Prime.app"

    # Unmount the .dmg file
    hdiutil detach "$dmg_volume"

    # Tidy Up
    sudo rm -rf $tmp_dir;
else
    echo "Application is already installed."
fi
