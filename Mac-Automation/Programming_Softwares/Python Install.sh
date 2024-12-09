#!/bin/bash

# Edit init vars here
software_name="Python"
# Define the URL
url="https://www.python.org/downloads/macos/"

# Download the raw HTML content from the webpage
html_content=$(curl -s --compressed "$url")

# Use sed to extract the first href that ends with .pkg
download_link=$(echo "$html_content" | sed -nE 's/.*href="([^"]+\.pkg)".*/\1/p' | head -1)

if [[ -n "$download_link" ]]; then
    echo "Download link: $download_link"
else
    echo "No .pkg download link found."
    exit 1
fi

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"
echo "$tmp_dir"

# Create an env variable for pkg install
pkg_path="$tmp_dir$software_name.pkg"
echo "$pkg_path"

# Check if app is already installed (using `ls` to handle wildcard)
if ls "/Applications/Python "*"/IDLE.app" 1> /dev/null 2>&1; then
    echo "Application is already installed."
else
    # Make temp folder for downloads safely
    mkdir -p "$tmp_dir" && cd "$tmp_dir" || { echo "Failed to create or navigate to $tmp_dir"; exit 1; }

    # curl and install
    curl -L -o "$pkg_path" "$download_link"

    # Check if download was successful
    if [[ ! -f "$pkg_path" ]]; then
        echo "Download failed."
        exit 1
    fi

    # Install .pkg file
    sudo installer -pkg "$pkg_path" -target /

    # Tidy up
    sudo rm -rf "$tmp_dir"

    # Verify installation
    if ls "/Applications/Python "*"/IDLE.app" 1> /dev/null 2>&1; then
        echo "App installed successfully."
    else
        echo "App did not install successfully..."
        exit 1
    fi
fi

