#!/bin/bash

# Extend swap file to 4gb via script
./swap.sh
# Check if the 'dialog' utility is installed
if ! command -v dialog &> /dev/null; then
  echo "The 'dialog' utility is not installed. Please install it to run this script."
  exit 1
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

# Update package manager repositories
show_message "Updating package manager repositories..."
sudo apt-get update

# Install Docker
show_message "Installing Docker..."
sudo apt-get install -y docker.io

# Install Docker Compose
show_message "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install OpenSSL
show_message "Installing OpenSSL..."
sudo apt-get install -y openssl

show_message "All dependency installation complete."

# Collect user input
domain=$(get_input "Enter the first domain name: ~domain.com")
mail_hostname=$(get_input "Enter the hostname ~mail.hostname.com")
admin_pass=$(get_input "Enter the domain admin password:")

# Create the .env file
rm .env
touch .env
echo "FIRST_MAIL_DOMAIN=$domain" >> .env
echo "HOSTNAME=$mail_hostname" >> .env
echo "FIRST_MAIL_DOMAIN_ADMIN_PASSWORD=$admin_pass" >> .env
echo "MLMMJADMIN_API_TOKEN=$(openssl rand -base64 32)" >> .env
echo "ROUNDCUBE_DES_KEY=$(openssl rand -base64 24)" >> .env

show_message "Configuration complete. .env file has been created."
