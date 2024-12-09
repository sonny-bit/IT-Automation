#!/bin/bash

# Specify the URL of the DMG file
url="https://builds.desktopapp.smartsheet.com/public/darwin/Smartsheet-setup.dmg"

# Specify the name of the software (without spaces)
softwareName="Smartsheet"

# Create the destination directory
destination="/tmp/$softwareName"
mkdir -p "$destination"

# Check if the application is already installed
if [ -d "/Applications/$softwareName.app" ]; then
    echo "$softwareName is already installed."
else
    # Download the DMG file
    if curl -L "$url" -o "$destination/$softwareName.dmg"; then
        echo "DMG file downloaded to: $destination/$softwareName.dmg"

        # Attach and install the software
        cd "$destination" || exit

        hdiutil mount "$softwareName.dmg" -mountpoint "/Volumes/$softwareName" && \
            productbuild --component "/Volumes/$softwareName/$softwareName.app" /Applications "$softwareName-setup.pkg" && \
            hdiutil detach "/Volumes/$softwareName"

        sudo installer -pkg "$softwareName-setup.pkg" -target /Applications
    else
        echo "Failed to download DMG file."
    fi
fi

