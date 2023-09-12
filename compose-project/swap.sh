#!/bin/bash

# Specify the desired swap file size in megabytes (4GB = 4096MB)
desired_swap_size_mb=4096

# Check if a swap file already exists
if [ -e /swapfile ]; then
    current_swap_size_kb=$(du -m /swapfile | cut -f1)
    
    # Check if the current swap size is less than the desired size
    if [ "$current_swap_size_kb" -lt "$desired_swap_size_mb" ]; then
        echo "Extending the existing swap file..."
        sudo swapoff /swapfile  # Turn off swap
        sudo dd if=/dev/zero of=/swapfile bs=1M count="$desired_swap_size_mb" status=progress
        sudo chmod 600 /swapfile  # Secure permissions
        sudo mkswap /swapfile  # Create swap space
        sudo swapon /swapfile  # Turn swap back on
        echo "Swap file extended to $desired_swap_size_mb MB."
    else
        echo "Swap file is already at or larger than the desired size."
    fi
else
    echo "No swap file found. Creating a new swap file..."
    sudo dd if=/dev/zero of=/swapfile bs=1M count="$desired_swap_size_mb" status=progress
    sudo chmod 600 /swapfile  # Secure permissions
    sudo mkswap /swapfile  # Create swap space
    sudo swapon /swapfile  # Turn on swap
    echo "Swap file created with size $desired_swap_size_mb MB."
fi

# Verify the current swap size
free -h