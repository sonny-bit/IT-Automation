#!/bin/bash

# Check if Firefox is running and close it
if pgrep -x "Firefox" > /dev/null; then
    echo "Closing Firefox..."
    osascript -e 'quit app "Firefox"'
    sleep 5  # Wait for Firefox to close completely
fi

# Download the latest version of Firefox
echo "Downloading latest Firefox version..."
curl -L -o firefox.dmg "https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US"

# Mount the DMG file without showing it in Finder or on the desktop
echo "Mounting Firefox DMG (hidden)..."
hdiutil attach firefox.dmg -nobrowse

# Install Firefox, replacing the old version
echo "Updating Firefox..."
cp -R "/Volumes/Firefox/Firefox.app" /Applications/

# Unmount the DMG
echo "Unmounting DMG..."
hdiutil detach "/Volumes/Firefox"

# Cleanup
echo "Cleaning up..."
rm firefox.dmg

# Reopen Firefox
echo "Reopening Firefox..."
open -a "Firefox"

# Notify user
echo "Firefox has been updated and reopened."

