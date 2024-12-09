#!/bin/bash

# Edit init vars here
software_name="Chrome"
URL="https://dl.google.com/dl/chrome/mac/universal/stable/gcem/GoogleChrome.pkg"

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"
echo $tmp_dir

# Create an env variable for pkg install
pkg_path=$tmp_dir$software_name.pkg
echo $pkg_path

# Check if app is already installed
# .apps are directories, not files (so use -d instead of -f)
if [ ! -d "/Applications/Google Chrome.app" ]; then 

    #Make temp folder for downloads. 
    mkdir $tmp_dir; cd $tmp_dir; 

    # curl and install
    curl -L -o $pkg_path $URL

    #install R
    sudo installer -pkg $pkg_path -target /; 

    #tidy up 
    sudo rm -rf $tmp_dir;
    
    # Check if app actually installed properly
    if [ ! -d "/Applications/Google Chrome.app" ]; then
        echo "Error. App did not install correctly..."
        exit 1
    else
        echo "Application installed successfully!"
    fi
else
    echo "Application is already installed."
fi


