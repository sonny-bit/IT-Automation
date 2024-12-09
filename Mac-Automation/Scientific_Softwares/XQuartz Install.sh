#!/bin/bash

# Edit init vars here
software_name="XQuartz"
org_link="https://www.xquartz.org/"

# Fetch the HTML content of the URL and search for the first .pkg link
URL=$(curl -s $org_link | grep -o 'https://[^\"]*\.pkg' | head -n 1)

# Check if a .pkg URL was found
if [ -n "$URL" ]; then
    echo "Found .pkg file: $URL"
else
    echo "No .pkg file found on the page."
    exit 1
fi

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"
echo $tmp_dir

# Create an env variable for pkg install
pkg_path=$tmp_dir$software_name.pkg
echo $pkg_path

# Check if app is already installed
# .apps are directories, not files (so use -d instead of -f)
if [ ! -d "/Applications/Utilities/$software_name.app" ]; then 

    #Make temp folder for downloads. 
    mkdir $tmp_dir; cd $tmp_dir; 

    # curl and install
    curl -L -o $pkg_path $URL

    #install R
    sudo installer -pkg $pkg_path -target /; 

    #tidy up 
    sudo rm -rf $tmp_dir;
else
    echo "Application is already installed."
fi
