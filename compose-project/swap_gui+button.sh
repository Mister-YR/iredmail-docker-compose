#!/bin/bash

# Get the current swap size
sudo apt-get install dialog -y
swap_resize() {
  dialog --title "Setup swap file check" --infobox "in progress..." 6 60

  # Check if swap exists
  SWAP_SIZE=$(free -g | grep Swap | awk '{print $2}')
  if [[ $SWAP_SIZE -eq 0 ]]; then

    # Create a new swap file
    sudo dd if=/dev/zero of=/swapfile bs=1M count=4096 | pv

    # Format the swap file
    sudo mkswap /swapfile

    # Enable the swap file
    sudo swapon /swapfile

    # Make the swap file permanent
    sudo echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

    dialog --title "Done!" --msgbox "Swap has been created and extended to 4 GB and made permanent." 6 60
    exit 0
  fi

  # Check if swap is less than 4 GB
  if [[ $SWAP_SIZE -lt 3 ]]; then

    # Drop the existing swap
    # sudo swapoff /swapfile
    dialog --title "drop existing swap" --msgbox "existing swap = $SWAP_SIZE will be dropped" 6 60
    sudo swapoff -v /swap.img
    rm -f /swap.img

    # Create a new swap file
    sudo dd if=/dev/zero of=/swapfile bs=1M count=5096 | pv

    # Format the swap file
    sudo mkswap /swapfile

    # Enable the swap file
    sudo swapon /swapfile

    # Make the swap file permanent
    sudo echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

    dialog --title "Create new Swap" --msgbox "Swap has been extended to 4 GB and made permanent."

  # else 
  #   # Swap is equal to 4 GB or greater
  # dialog --title "swap already exist" --msgbox "Swap is already equal to 4 GB or greater."

  #   exit 0
  fi

  # Swap is equal to 4 GB or greater
  dialog --title "swap already exist" --msgbox "Swap is already equal to 4 GB or greater."

  if [[ $SWAP_SIZE -ge 3 ]]; then
  dialog --title "Swap is already equal to or more than 4 GB." --msgbox "Skipping..." 6 60
  exit 0
  fi
}


#main menu
# Main menu
while true; do
    choice=$(dialog --clear --title "Package Management Menu" --menu "Choose an option:" 12 60 4 \
        1 "Resize or Create swap file" \
        2 "Exit" 2>&1 >/dev/tty)

    case $choice in
        1)
            swap_resize
            ;;
        2)
            exit 0 
            ;;
        *)
            ;;
    esac
done