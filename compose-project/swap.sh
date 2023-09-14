#!/bin/bash

# Get the current swap size
SWAP_SIZE=$(free -g | grep Swap | awk '{print $2}')

# Check if swap exists
if [[ $SWAP_SIZE -eq 0 ]]; then
  echo "Swap does not exist."

  # Create a new swap file
  sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
  # Format the swap file
  sudo mkswap /swapfile
  # Enable the swap file
  sudo swapon /swapfile

  # Make the swap file permanent
  sudo echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

  echo "Swap has been created and extended to 4 GB and made permanent."
  exit 0
fi

# Check if swap is less than 4 GB
if [[ $SWAP_SIZE -lt 4 ]]; then
  # Drop the existing swap
#  sudo swapoff /swapfile
  sudo swapoff -v /swap.img
  rm -f /swap.img 

  # Create a new swap file
  sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
  # Format the swap file
  sudo mkswap /swapfile
  # Enable the swap file
  sudo swapon /swapfile

  # Make the swap file permanent
  sudo echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

  echo "Swap has been extended to 4 GB and made permanent."
  exit 0
fi

# Swap is equal to 4 GB or greater
echo "Swap is already equal to 4 GB or greater."
# Verify the current swap size
free -h