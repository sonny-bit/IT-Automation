#!/bin/bash

# Initialize variables
software_name="PyCharm CE"
url="https://www.jetbrains.com/pycharm/download/?section=mac"
version_pattern='[0-9]{4}\.[0-9]+\.[0-9]+'

# Get the latest version from the website
html_content=$(curl -s "$url")

# Use sed to find the version number in the HTML content
version=$(echo "$html_content" | sed -nE "s/.*($version_pattern).*/\1/p" | head -1)

if [[ -n "$version" ]]; then
    # Construct the download link for the PyCharm DMG file
    URL_Silicon="https://download-cdn.jetbrains.com/python/pycharm-community-$version-aarch64.dmg"
    echo "Download link: $URL_Silicon"
else
    echo "Version number not found."
    exit 1
fi

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"
echo "$tmp_dir"

# Create an env variable for dmg install
dmg_path="$tmp_dir$software_name.dmg"
echo "$dmg_path"

# Check if app is already installed
if [ ! -d "/Applications/$software_name.app" ]; then 

    # Make temp folder for downloads
    mkdir -p "$tmp_dir"; cd "$tmp_dir"; 

    # Check if system is Intel or Silicon, then curl
    if [ "$(uname -m)" == "x86_64" ]; then
        echo "This Mac contains an Intel chip... Please manually install."
        exit 1
    elif [ "$(uname -m)" == "arm64" ]; then
        curl -L -o "$dmg_path" "$URL_Silicon"
    fi

    # Mount the .dmg file
    hdiutil attach "$dmg_path"

    # Install the application from the mounted .dmg file
    app_path="/Volumes/$software_name/$software_name.app"
    echo "$app_path"
    sudo cp -R "$app_path" /Applications/

    # Unmount the .dmg file
    hdiutil detach "/Volumes/$software_name"

    # Tidy up
    sudo rm -rf "$tmp_dir"

    # Verify installation
    if [ ! -d "/Applications/$software_name.app" ]; then
        echo "Error. App did not install correctly..."
        exit 1
    else
        echo "Application installed successfully!"
    fi
else
    echo "Application is already installed."
fi

