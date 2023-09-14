#!/bin/bash
#install dialog
sudo apt-get install dialog -y
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
swap_check=$(free -h | grep 'Swap' | awk '{print $2}')
show_message "$swap_check"
# Main menu
while true; do
    choice=$(dialog --clear --title "Package Management Menu" --menu "Choose an option:" 12 60 4 \
        1 "extend swaps to 4GB" \
        2 "Exit" 2>&1 >/dev/tty)

    case $choice in
        1)
            # Extend swap file to 4gb
            $desired_swap_size_mb=4096
            show_message "swap size must been 4 gb or greather"
            # Check if a swap file already exists
            # Specify the desired swap file size in megabytes (4GB = 4096MB)
            desired_swap_size_mb=4096
            swap_check=$(free -h | grep 'Swap' | awk '{print $2}')

            # Check if a swap file already exists
        if [ -e /swapfile ]; then
                current_swap_size_kb=$(du -m /swapfile | cut -f1)
    
            # Check if the current swap size is less than the desired size
            if [ "$current_swap_size_kb" -lt "$desired_swap_size_mb" ]; then
                show_message "Extending the existing swap file..."
                sudo swapoff /swapfile  # Turn off swap
                sudo dd if=/dev/zero of=/swapfile bs=1M count="$desired_swap_size_mb" status=progress
                sudo chmod 600 /swapfile  # Secure permissions
                sudo mkswap /swapfile  # Create swap space
                sudo swapon /swapfile  # Turn swap back on
                show_message "Swap file extended to $swap_check MB."
            else
                show_message "Swap file is already at or larger than the desired size."
            fi
        else
            show_message "No swap file found. Creating a new swap file..."
            sudo dd if=/dev/zero of=/swapfile bs=1M count="$desired_swap_size_mb" status=progress
            sudo chmod 600 /swapfile  # Secure permissions
            sudo mkswap /swapfile  # Create swap space
            sudo swapon /swapfile  # Turn on swap
            show_message "$swap_check"
        fi
            ;;
        2)
            exit
            ;;
        *)
            ;;
    esac
done