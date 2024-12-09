#!/bin/bash

# Define variables
APP_NAME="Windows App" 
APP_PATH="/Applications/$APP_NAME.app"
DOWNLOAD_URL="https://go.microsoft.com/fwlink/?linkid=868963"
TEMP_DIR="/tmp"
PKG_NAME="RemoteDesktop.pkg"
PKG_PATH="$TEMP_DIR/$PKG_NAME"

# Check if the application is already installed
if [ -d "$APP_PATH" ]; then
    echo "$APP_NAME is already installed in /Applications."
    exit 0
fi

# Download the package to the temporary directory
echo "Downloading $APP_NAME..."
curl -L -o "$PKG_PATH" "$DOWNLOAD_URL"

# Check if download was successful
if [ ! -f "$PKG_PATH" ]; then
    echo "Failed to download $APP_NAME package."
    exit 1
fi

# Install the package silently
echo "Installing $APP_NAME..."
sudo installer -pkg "$PKG_PATH" -target /

# Check if the installation was successful
if [ -d "$APP_PATH" ]; then
    echo "$APP_NAME was successfully installed."
    # Remove the downloaded package after successful installation
    rm -f "$PKG_PATH"
    exit 0
else
    echo "Installation of $APP_NAME failed."
    # Remove the downloaded package even if the installation failed
    rm -f "$PKG_PATH"
    exit 1
fi
