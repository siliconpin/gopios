#!/bin/bash

# DAG List Menu Script
# This script displays a dialog menu with options to Get Script, Get App, and Update menu

MENU_URL="https://apprepogopios.siliconpin.com/gopios/v1/DAG/menu.txt"
TEMP_MENU="/tmp/dag_menu.txt"
DIALOG_HEIGHT=20
DIALOG_WIDTH=60

# Function to check if dialog is installed
check_dialog() {
    if ! command -v dialog &> /dev/null; then
        echo "Error: 'dialog' command not found. Please install it first."
        exit 1
    fi
}

# Function to build the menu options array
build_menu() {
    local menu_file=$1
    MENU_OPTIONS=()
    
    # Default menu items
    MENU_OPTIONS+=("1" "Get Script")
    MENU_OPTIONS+=("2" "Get App")
    MENU_OPTIONS+=("3" "Update Menu")
    MENU_OPTIONS+=("4" "Generate GPG Key")
    
    # If menu file exists, add items from it (each line is a new menu item)
    if [ -f "$menu_file" ]; then
        local counter=5
        while IFS= read -r line || [ -n "$line" ]; do
            # Skip empty lines and trim whitespace
            line=$(echo "$line" | xargs)
            [ -z "$line" ] && continue
            
            MENU_OPTIONS+=("$counter" "$line")
            ((counter++))
        done < "$menu_file"
    fi
    
    MENU_OPTIONS+=("0" "Exit")
}

# Function to fetch menu items from URL
update_menu() {
    dialog --infobox "Fetching menu items from server..." 5 50
    sleep 1
    
    if curl -s -f -o "$TEMP_MENU" "$MENU_URL" 2>/dev/null; then
        dialog --msgbox "Menu updated successfully!" 6 40
        return 0
    else
        dialog --msgbox "Failed to fetch menu from:\n$MENU_URL\n\nPlease check your internet connection." 10 50
        return 1
    fi
}

# Function to handle Get Script option
get_script() {
    local SCRIPTS_LIST_URL="https://apprepogopios.siliconpin.com/gopios/v1/DAG/scripts.txt"
    local SCRIPTS_BASE_URL="https://apprepogopios.siliconpin.com/gopios/v1/DAG/apps/scripts/"
    local DOWNLOAD_DIR="$HOME/Desktop/Apps/scripts"
    local TEMP_SCRIPTS_LIST="/tmp/dag_scripts.txt"
    
    # Create download directory if it doesn't exist
    mkdir -p "$DOWNLOAD_DIR"
    
    # Fetch the scripts list
    dialog --infobox "Fetching available scripts..." 5 50
    sleep 1
    
    if ! curl -s -f -o "$TEMP_SCRIPTS_LIST" "$SCRIPTS_LIST_URL" 2>/dev/null; then
        dialog --msgbox "Failed to fetch scripts list from:\n$SCRIPTS_LIST_URL\n\nPlease check your internet connection." 10 60
        return 1
    fi
    
    # Check if file is empty
    if [ ! -s "$TEMP_SCRIPTS_LIST" ]; then
        dialog --msgbox "No scripts found in the list." 6 40
        return 1
    fi
    
    # Build script selection menu
    local SCRIPT_OPTIONS=()
    local counter=1
    while IFS= read -r scriptname || [ -n "$scriptname" ]; do
        scriptname=$(echo "$scriptname" | xargs)
        [ -z "$scriptname" ] && continue
        SCRIPT_OPTIONS+=("$counter" "$scriptname")
        ((counter++))
    done < "$TEMP_SCRIPTS_LIST"
    
    # Add cancel option
    SCRIPT_OPTIONS+=("0" "Cancel")
    
    # Show script selection dialog
    exec 3>&1
    SELECTED_INDEX=$(dialog --clear \
        --title "Select Script to Download" \
        --menu "Choose a script:" \
        20 70 10 \
        "${SCRIPT_OPTIONS[@]}" \
        2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    
    # Check if user cancelled
    if [ $exit_status -ne 0 ] || [ "$SELECTED_INDEX" = "0" ]; then
        rm -f "$TEMP_SCRIPTS_LIST"
        return 0
    fi
    
    # Get the selected script name
    scriptname=$(sed -n "${SELECTED_INDEX}p" "$TEMP_SCRIPTS_LIST" | xargs)
    
    # Download script
    local TEMP_DOWNLOAD="/tmp/dag_download_$$"
    dialog --infobox "Downloading: $scriptname" 5 50
    
    if curl -L -f -s -o "$TEMP_DOWNLOAD" "${SCRIPTS_BASE_URL}${scriptname}"; then
        # Check if download was successful and file is not empty
        if [ -f "$TEMP_DOWNLOAD" ] && [ -s "$TEMP_DOWNLOAD" ]; then
            mv "$TEMP_DOWNLOAD" "$DOWNLOAD_DIR/$scriptname"
            chmod +x "$DOWNLOAD_DIR/$scriptname"
            dialog --msgbox "Download complete!\n\nScript: $scriptname\nSaved to: $DOWNLOAD_DIR/" 9 60
        else
            dialog --msgbox "Download failed: $scriptname\n\nFile is empty or missing." 8 60
        fi
    else
        dialog --msgbox "Download failed: $scriptname\n\nHTTP error or connection issue." 8 60
    fi
    
    # Clean up
    [ -f "$TEMP_DOWNLOAD" ] && rm -f "$TEMP_DOWNLOAD"
    rm -f "$TEMP_SCRIPTS_LIST"
}

# Function to handle Get App option
get_app() {
    local APPS_LIST_URL="https://apprepogopios.siliconpin.com/gopios/v1/DAG/apps.txt"
    local APPS_BASE_URL="https://apprepogopios.siliconpin.com/gopios/v1/DAG/apps/"
    local DOWNLOAD_DIR="$HOME/Desktop/Apps"
    local TEMP_APPS_LIST="/tmp/dag_apps.txt"
    
    # Create download directory if it doesn't exist
    mkdir -p "$DOWNLOAD_DIR"
    
    # Fetch the apps list
    dialog --infobox "Fetching available applications..." 5 50
    sleep 1
    
    if ! curl -s -f -o "$TEMP_APPS_LIST" "$APPS_LIST_URL" 2>/dev/null; then
        dialog --msgbox "Failed to fetch apps list from:\n$APPS_LIST_URL\n\nPlease check your internet connection." 10 60
        return 1
    fi
    
    # Check if file is empty
    if [ ! -s "$TEMP_APPS_LIST" ]; then
        dialog --msgbox "No applications found in the list." 6 40
        return 1
    fi
    
    # Build app selection menu
    local APP_OPTIONS=()
    local counter=1
    while IFS= read -r appname || [ -n "$appname" ]; do
        appname=$(echo "$appname" | xargs)
        [ -z "$appname" ] && continue
        APP_OPTIONS+=("$counter" "$appname")
        ((counter++))
    done < "$TEMP_APPS_LIST"
    
    # Add cancel option
    APP_OPTIONS+=("0" "Cancel")
    
    # Show app selection dialog
    exec 3>&1
    SELECTED_INDEX=$(dialog --clear \
        --title "Select Application to Download" \
        --menu "Choose an application:" \
        20 70 10 \
        "${APP_OPTIONS[@]}" \
        2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    
    # Check if user cancelled
    if [ $exit_status -ne 0 ] || [ "$SELECTED_INDEX" = "0" ]; then
        rm -f "$TEMP_APPS_LIST"
        return 0
    fi
    
    # Get the selected app name
    appname=$(sed -n "${SELECTED_INDEX}p" "$TEMP_APPS_LIST" | xargs)
    
    # Download app
    local TEMP_DOWNLOAD="/tmp/dag_download_$$"
    dialog --infobox "Downloading: $appname" 5 50
    
    if curl -L -f -s -o "$TEMP_DOWNLOAD" "${APPS_BASE_URL}${appname}"; then
        # Check if download was successful and file is not empty
        if [ -f "$TEMP_DOWNLOAD" ] && [ -s "$TEMP_DOWNLOAD" ]; then
            mv "$TEMP_DOWNLOAD" "$DOWNLOAD_DIR/$appname"
            chmod +x "$DOWNLOAD_DIR/$appname"
            dialog --msgbox "Download complete!\n\nApplication: $appname\nSaved to: $DOWNLOAD_DIR/" 9 60
        else
            dialog --msgbox "Download failed: $appname\n\nFile is empty or missing." 8 60
        fi
    else
        dialog --msgbox "Download failed: $appname\n\nHTTP error or connection issue." 8 60
    fi
    
    # Clean up
    [ -f "$TEMP_DOWNLOAD" ] && rm -f "$TEMP_DOWNLOAD"
    rm -f "$TEMP_APPS_LIST"
}

# Function to handle dynamic menu items
handle_dynamic_option() {
    local option=$1
    local description=$2
    dialog --msgbox "Selected: $description\n\nOption number: $option" 8 50
}

# Function to generate GPG key
generate_gpg_key() {
    # Check if GPG is installed
    if ! command -v gpg &> /dev/null; then
        dialog --msgbox "Error: GPG is not installed on your system.\n\nPlease install it first:\n\nUbuntu/Debian: sudo apt-get install gnupg\nCentOS/RHEL: sudo yum install gnupg" 12 60
        return 1
    fi
    
    # Ask for key type
    exec 3>&1
    KEY_TYPE=$(dialog --clear \
        --title "Key Type" \
        --menu "Select key type:" \
        12 60 3 \
        "1" "RSA and RSA (default)" \
        "2" "DSA and Elgamal" \
        "3" "ECDSA and ECDH" \
        2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    
    if [ $exit_status -ne 0 ]; then
        return 0
    fi
    
    case $KEY_TYPE in
        1) KEY_TYPE_CMD="1" ;;
        2) KEY_TYPE_CMD="2" ;;
        3) KEY_TYPE_CMD="3" ;;
        *) KEY_TYPE_CMD="1" ;;
    esac
    
    # Ask for key size
    exec 3>&1
    KEY_SIZE=$(dialog --clear \
        --title "Key Size" \
        --inputbox "Enter key size (2048-4096):\n\nRecommended: 4096" \
        12 60 "4096" \
        2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    
    if [ $exit_status -ne 0 ]; then
        return 0
    fi
    
    # Validate key size
    if ! [[ "$KEY_SIZE" =~ ^[0-9]+$ ]] || [ "$KEY_SIZE" -lt 2048 ] || [ "$KEY_SIZE" -gt 4096 ]; then
        dialog --msgbox "Invalid key size. Please enter a number between 2048 and 4096." 8 60
        return 1
    fi
    
    # Ask for name
    exec 3>&1
    NAME=$(dialog --clear \
        --title "Real Name" \
        --inputbox "Enter your real name:" \
        10 60 \
        2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    
    if [ $exit_status -ne 0 ] || [ -z "$NAME" ]; then
        dialog --msgbox "Name is required for GPG key generation." 8 60
        return 1
    fi
    
    # Ask for email
    exec 3>&1
    EMAIL=$(dialog --clear \
        --title "Email Address" \
        --inputbox "Enter your email address:" \
        10 60 \
        2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    
    if [ $exit_status -ne 0 ] || [ -z "$EMAIL" ]; then
        dialog --msgbox "Email is required for GPG key generation." 8 60
        return 1
    fi
    
    # Ask for passphrase
    exec 3>&1
    PASSPHRASE=$(dialog --clear \
        --title "Passphrase" \
        --passwordbox "Enter passphrase for the key (leave empty for no passphrase):" \
        12 60 \
        2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    
    if [ $exit_status -ne 0 ]; then
        return 0
    fi
    
    # Ask for passphrase confirmation if provided
    if [ -n "$PASSPHRASE" ]; then
        exec 3>&1
        PASSPHRASE_CONFIRM=$(dialog --clear \
            --title "Confirm Passphrase" \
            --passwordbox "Confirm passphrase:" \
            12 60 \
            2>&1 1>&3)
        exit_status=$?
        exec 3>&-
        
        if [ $exit_status -ne 0 ]; then
            return 0
        fi
        
        if [ "$PASSPHRASE" != "$PASSPHRASE_CONFIRM" ]; then
            dialog --msgbox "Passphrases do not match. Please try again." 8 60
            return 1
        fi
    fi
    
    # Show confirmation
    dialog --clear \
        --title "Confirmation" \
        --yesno "Generate GPG key with the following settings?\n\nName: $NAME\nEmail: $EMAIL\nKey Type: $([ "$KEY_TYPE_CMD" = "1" ] && echo "RSA" || [ "$KEY_TYPE_CMD" = "2" ] && echo "DSA" || echo "ECDSA")\nKey Size: $KEY_SIZE\nPassphrase: $(if [ -n "$PASSPHRASE" ]; then echo "Yes"; else echo "No"; fi)" \
        14 60
    
    if [ $? -ne 0 ]; then
        dialog --msgbox "Key generation cancelled." 6 40
        return 0
    fi
    
    # Create batch configuration file
    BATCH_FILE="/tmp/gpg_batch_$$"
    cat > "$BATCH_FILE" << EOF
%echo Generating a GPG key
Key-Type: $KEY_TYPE_CMD
Key-Length: $KEY_SIZE
Subkey-Type: $KEY_TYPE_CMD
Subkey-Length: $KEY_SIZE
Name-Real: $NAME
Name-Email: $EMAIL
Expire-Date: 0
$(if [ -n "$PASSPHRASE" ]; then echo "Passphrase: $PASSPHRASE"; else echo "%no-protection"; fi)
%commit
%echo Done
EOF
    
    # Generate the key with progress indication
    (
        echo "10" ; sleep 0.5
        echo "XXX"
        echo "Generating GPG key..."
        echo "XXX"
        
        echo "30" ; sleep 0.5
        echo "XXX"
        echo "Setting up key parameters..."
        echo "XXX"
        
        echo "50" ; sleep 0.5
        echo "XXX"
        echo "Creating master key..."
        echo "XXX"
        
        # Generate the key
        if gpg --batch --generate-key "$BATCH_FILE" 2>/dev/null; then
            echo "90" ; sleep 0.5
            echo "XXX"
            echo "Finalizing key generation..."
            echo "XXX"
            echo "100"
        else
            echo "100"
        fi
    ) | dialog --title "Generating GPG Key" --gauge "Please wait..." 10 70 0
    
    # Check if key generation was successful
    if gpg --list-keys "$EMAIL" &>/dev/null; then
        KEY_ID=$(gpg --list-keys "$EMAIL" | grep -oP 'rsa\d+/\K[0-9A-F]+' | head -1)
        
        dialog --msgbox "GPG key generated successfully!\n\nKey ID: $KEY_ID\nName: $NAME\nEmail: $EMAIL\n\nKey has been added to your keyring." 12 70
        
        # Offer to export public key
        if dialog --yesno "Would you like to export your public key to a file?" 8 60; then
            EXPORT_FILE="$HOME/Desktop/${NAME}_public-key.asc"
            gpg --armor --export "$EMAIL" > "$EXPORT_FILE"
            dialog --msgbox "Public key exported to:\n$EXPORT_FILE" 8 60
        fi
    else
        dialog --msgbox "Failed to generate GPG key. Please check the parameters and try again." 8 60
    fi
    
    # Clean up
    rm -f "$BATCH_FILE"
}

# Main function
main() {
    check_dialog
    
    # Clear any existing temp menu file on start
    [ -f "$TEMP_MENU" ] && rm -f "$TEMP_MENU"
    
    while true; do
        # Build menu with current options
        build_menu "$TEMP_MENU"
        
        # Display menu and get selection using proper file descriptor redirection
        exec 3>&1
        CHOICE=$(dialog --clear \
            --title "DAG List Menu - Main Menu" \
            --menu "Choose an option:" \
            $DIALOG_HEIGHT $DIALOG_WIDTH 10 \
            "${MENU_OPTIONS[@]}" \
            2>&1 1>&3)
        exit_status=$?
        exec 3>&-
        
        # Check if user cancelled
        if [ $exit_status -ne 0 ]; then
            clear
            exit 0
        fi
        
        # Handle selection
        case $CHOICE in
            1)
                get_script
                ;;
            2)
                get_app
                ;;
            3)
                update_menu
                ;;
            4)
                generate_gpg_key
                ;;
            0)
                clear
                echo "Exiting DAG List Menu. Goodbye!"
                exit 0
                ;;
            *)
                # Handle dynamic menu items
                if [ -f "$TEMP_MENU" ]; then
                    line_num=$((CHOICE - 4))
                    description=$(sed -n "${line_num}p" "$TEMP_MENU")
                    handle_dynamic_option "$CHOICE" "$description"
                else
                    dialog --msgbox "Invalid option. Please try again." 6 40
                fi
                ;;
        esac
    done
}

# Run the main function
main