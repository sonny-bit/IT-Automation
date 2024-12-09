#!/bin/bash

# Edit init vars here
software_name="DisplayLink"

# Get the latest URL link
# Step 1: Navigate to the website and fetch the HTML content
url="https://www.synaptics.com/products/displaylink-graphics/downloads/macos"
html_content=$(curl -s "$url")

# Step 2: Find the first URL with the 'Download' button
download_link=$(echo "$html_content" | grep -o '<a href="[^"]*" class="download-link">Download</a>' | head -n 1 | cut -d'"' -f2)

# Check if the download link was found
if [ -z "$download_link" ]; then
    echo "Download link not found."
    exit 1
fi

# Step 3: Construct the full download URL
full_download_url="https://www.synaptics.com$download_link"

# Step 4: Fetch the download page to get the final URL
download_page_content=$(curl -s "$full_download_url")

# Step 5: Find the .pkg file URL from the 'Accept' link
final_url=$(echo "$download_page_content" | grep -o '<a class="no-link" href="[^"]*" download>Accept</a>' | sed 's/.*href="\([^"]*\).*/\1/')

# Check if the final URL was found
if [ -z "$final_url" ]; then
    echo "Final URL not found."
    exit 1
fi

# Construct the full URL for the final download
URL="https://www.synaptics.com$final_url"  # Add the base URL to the final path

### Automated Code
# Create tmp directory
tmp_dir="/tmp/$software_name/"
echo $tmp_dir

# Create an env variable for pkg install
pkg_path=$tmp_dir$software_name.pkg
echo $pkg_path

# Check if app is already installed
# .apps are directories, not files (so use -d instead of -f)
if [ ! -d "/Applications/DisplayLink Manager.app" ]; then 

    #Make temp folder for downloads. 
    mkdir $tmp_dir; cd $tmp_dir; 

    # curl and install
    curl -L -o $pkg_path $URL

    #install R
    sudo installer -pkg $pkg_path -target /; 

    #tidy up 
    sudo rm -rf $tmp_dir;
    # Check if app actually installed properly
    if [ ! -d "/Applications/DisplayLink Manager.app" ]; then
        echo "Error. App did not install correctly..."
        exit 1
    else
        echo "Application installed successfully!"
    fi
else
    echo "Application is already installed."
fi
