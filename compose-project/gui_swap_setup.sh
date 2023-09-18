#!/bin/bash
# Check if the 'dialog' utility present
if ! command -v dialog &> /dev/null; then
  echo "Installing dialog utility ( ^_^)／"
  sudo apt-get install dialog -y
fi
# Function to display an input dialog and store the result in a variable
get_input() {
  local result
  result=$(dialog --inputbox "$1" 10 40 3>&1 1>&2 2>&3)
  echo "$result"
}

# Function to display a message dialog
show_message() {
  dialog --msgbox "$1" 10 40
}

swap_resize() {
  # Check if swap exists 
    SWAP_SIZE=$(free -g | grep Swap | awk '{print $2}')
  if [[ $SWAP_SIZE -eq 0 ]]; then
      # Create a new swap file
      sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
      # Format the swap file
      sudo mkswap /swapfile
      # Enable the swap file
      sudo swapon /swapfile
      # Make the swap file permanent
      sudo echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
      dialog --title "Done!" --msgbox "Swap has been created and extended to 4 GB and made permanent. (◔_◔)🍔🍕" 6 60

  elif [[ $SWAP_SIZE -lt 3 ]]; then
  # if swap less than 4GB
      dialog --title "drop existing swap" --msgbox "existing swap = $SWAP_SIZE will be dropped ( ͡° ͜ʖ ͡°) " 6 60
      sudo swapoff -v /swap.img
      rm -f /swap.img 
      sudo swapoff /swapfile
      # Create a new swap file
      sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
      # Format the swap file
      sudo mkswap /swapfile
      sudo chmod 600 /swapfile  # Secure permissions
      # Enable the swap file
      sudo swapon /swapfile
      # Make the swap file permanent
      sudo echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
      dialog --title "Create new Swap" --msgbox "Swap has been extended to 4 GB and made permanent."

  else
      # Swap is equal to or greater than 4 GB
      dialog --title "Swap is already equal to or more than 4 GB 👍" --msgbox "Skipping..." 6 60
  fi
}
# Main menu
while true; do
    choice=$(dialog --clear --title "Package Management Menu" --menu "Choose an option:" 12 60 4 \
        1 "Resize or Create swap file" \
        2 "install dependency" 2>&1 >/dev/tty)

    case $choice in
        1)
            swap_resize
            ;;
        2)
            # processing to install...
            echo "Processing to update & install dependency..."
            sleep 2
            clear
            break
            ;;
        *)
            ;;
    esac
done