#!/bin/bash

# Function to update package repositories with progress bar
update_repositories() {
    dialog --title "Updating Package Repositories" --infobox "Please wait while updating..." 6 60
    # Run apt-get update in the background and capture the output
    apt-get update &> /tmp/update_log
    # Check the exit status of apt-get update
    if [ $? -eq 0 ]; then
        dialog --title "Update Complete" --msgbox "Package repositories have been updated successfully." 6 60
    else
        dialog --title "Update Error" --msgbox "An error occurred while updating package repositories. Check /tmp/update_log for details." 6 60
    fi
    # Clean up the temporary log file
    rm /tmp/update_log
}

# Main menu
while true; do
    choice=$(dialog --clear --title "Package Management Menu" --menu "Choose an option:" 12 60 4 \
        1 "Update Package Repositories" \
        2 "Install Software" \
        3 "Remove Software" \
        4 "Exit" 2>&1 >/dev/tty)

    case $choice in
        1)
            update_repositories
            ;;
        2)
            # Add your software installation code here
            ;;
        3)
            # Add your software removal code here
            ;;
        4)
            exit
            ;;
        *)
            ;;
    esac
done

