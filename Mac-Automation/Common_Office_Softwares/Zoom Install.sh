#!/bin/bash

# Ref: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0058493
## Ref#2: https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0064957

# Remove all previous zoom preferences
rm -f "/Library/Preferences/us.zoom.config.plist"
rm -f "/Library/Managed Preferences/us.zoom.config.plist"

# Reinstalling Zoom with .pkg file
software_name="zoom.us"
URL_silicon="https://zoom.us/client/latest/ZoomInstallerIT.pkg?archType=arm64"

# Create tmp directory
tmp_dir="/tmp/$software_name"
rm -rf "$tmp_dir"
echo "$tmp_dir"

# Move .plist file to the right directory
# Define source and destination paths
source_file="/tmp/us.zoom.config.plist"
destination_dir="/tmp/zoom.us/"

# Check if the source file exists
if [ -f "$source_file" ]; then
    # Create the destination directory if it doesn't exist
    mkdir -p "$destination_dir"

    # Move the plist file to the destination directory
    mv "$source_file" "$destination_dir"

    echo "us.zoom.config.plist moved to $destination_dir"
else
    echo "Error: $source_file not found."
fi

# Check if app is already installed
if [ ! -d "/Applications/$software_name.app" ]; then 
    # Make temp folder for downloads
    mkdir -p "$tmp_dir" || { echo "Failed to create temporary directory"; exit 1; }

    # Download Zoom package
    echo "Downloading Zoom package..."
    curl -L -o "$tmp_dir/ZoomInstallerIT.pkg" "$URL_silicon" || { echo "Failed to download package"; exit 1; }

    echo "Installing Zoom for Silicon"
    # Install Zoom
    sudo installer -pkg "$tmp_dir/ZoomInstallerIT.pkg" -target / || { echo "Failed to install Zoom"; exit 1; }

    # Clean up
    rm -rf "$tmp_dir"

    # Check one last time if the app installed
    if [ ! -d "/Applications/$software_name.app" ]; then 
        echo "Error: Application failed to install"
        exit 1
    else
        echo "Application successfully installed!"
    fi
else
    echo "Application is already installed."
fi


