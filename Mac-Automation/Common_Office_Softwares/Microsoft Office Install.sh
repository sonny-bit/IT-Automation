#!/bin/bash 

# Init vars 
software_name="MSOffice"
URL="[Retrieve direct link from MSOffice Admin page for .pkg file]"

# START OF CODE 
apps_installed=0

# Array of Microsoft app names to check
microsoft_apps=("Microsoft Word.app" "Microsoft Excel.app" "Microsoft PowerPoint.app" "Microsoft Outlook.app" "Microsoft OneNote.app" "OneDrive.app")

# Function to check if an app is installed
check_app_installed() {
    if [ -d "/Applications/$1" ]; then
        echo "$1 is still installed? Yes"
        apps_installed=1
    else
        echo "$1 is still installed? No"
    fi
}

# Loop through the array of Microsoft app names
for app_name in "${microsoft_apps[@]}"; do
    check_app_installed "$app_name"
done

# If any app is missing, prepare installation
if [ $apps_installed -eq 1 ]; then 
    echo "Some Microsoft Office apps are still installed. Please remove them before running the installer, or manually install your missing applications" 
else 
    echo "All Microsoft apps are missing... Preparing installation" 
    # Create tmp directory 
    tmp_dir="/tmp/$software_name/" 
    echo $tmp_dir 

    # Create an env variable for pkg install
    pkg_path=$tmp_dir$software_name.pkg 
    echo $pkg_path 

    #Make temp folder for downloads. 
    mkdir $tmp_dir; cd $tmp_dir; 
    
    # curl and install 
    curl -L -o $pkg_path $URL 
    
    #install MS Office
    sudo installer -pkg $pkg_path -target /; 
    
    #tidy up 
    sudo rm -rf $tmp_dir; 

    # Check if app actually installed properly
    if [ ! -d "/Applications/Microsoft Word.app" ]; then
        echo "Error. App did not install correctly..."
        exit 1
    else
        echo "Application installed successfully!"
    fi
fi
