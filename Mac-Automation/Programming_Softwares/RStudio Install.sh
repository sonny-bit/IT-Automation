#!/bin/bash

# Edit init vars here
software_name="RStudio"

# Define the URL
url="https://posit.co/download/rstudio-desktop/"

# Download the raw HTML content from the webpage
html_content=$(curl -s --compressed "$url")

# Use sed to extract the first href that ends with .dmg
download_link=$(echo "$html_content" | sed -nE 's/.*href="([^"]+\.dmg)".*/\1/p' | head -1)

if [[ -n "$download_link" ]]; then
    echo "Download link: $download_link"
else
    echo "No .dmg download link found."
    exit 1
fi

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"
echo "$tmp_dir"

# Create an env variable for dmg install
dmg_path="$tmp_dir$software_name.dmg"

# Check if app is already installed (using `ls` to handle wildcard)
if [ -d "/Applications/$software_name.app" ]; then
    echo "Application is already installed."
else
    # Make temp folder for downloads safely
    mkdir -p "$tmp_dir" && cd "$tmp_dir" || { echo "Failed to create or navigate to $tmp_dir"; exit 1; }

    # curl and install
    curl -L -o "$dmg_path" "$download_link"

    # Check if download was successful
    if [[ ! -f "$dmg_path" ]]; then
        echo "Download failed."
        exit 1
    fi

    # Mount the .dmg file
    hdiutil attach "$dmg_path"

    # Get the volume name of the .dmg file
    dmg_volume=$(hdiutil info | grep '/Volumes/' | grep 'RStudio.*' | awk '{print $3}')
    echo $dmg_volume

    # Install the application from the mounted .dmg file
    app_path="$dmg_volume/$software_name.app"
    echo $app_path
    sudo cp -R $app_path /Applications/

    # Unmount the .dmg file
    hdiutil detach "$dmg_volume"

    # Tidy up
    sudo rm -rf "$tmp_dir"

    # Verify installation
    if [ -d "/Applications/$software_name.app" ]; then
        echo "App installed successfully."
    else
        echo "App did not install successfully..."
        exit 1
    fi
fi
