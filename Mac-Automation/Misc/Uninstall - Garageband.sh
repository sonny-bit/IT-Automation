#!/bin/bash

# Check if GarageBand is installed
if [ -d "/Applications/GarageBand.app" ]; then
    echo "GarageBand is installed. Uninstalling..."
    sudo rm -rf "/Applications/GarageBand.app"
    if [ -d "/Applications/GarageBand.app" ]; then
        echo "GarageBand did not uninstall successfully... Try again"
        exit 1699
    else
        echo "GarageBand has been uninstalled successfully."
    fi
else
    echo "GarageBand is not installed... Exiting"
fi
