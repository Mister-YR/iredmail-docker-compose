#!/bin/bash
######################################################
# Description: one-file-gui_setup.sh
# Author: Mister-YR
# Link: https://github.com/Mister-YR/iredmail-docker-compose.git
# Version: 4.0
######################################################
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

# Verify the current swap size
swap_check=$(free -h | grep 'Swap' | awk '{print $2}')
show_message " Current swap size - $swap_check 👍"
######################################################
# Description: install all denendency
# Version: 4.0
######################################################
# Update package manager repositories
show_message "install all dependency"
# Update repos
sudo apt-get update

# Install Docker
show_message "Installing Docker..."
sudo apt-get install -y docker.io

# Install Docker Compose
show_message "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Install OpenSSL
show_message "Installing OpenSSL..."
sudo apt-get install -y openssl

show_message "All dependency installation complete."

# Collect user input
domain=$(get_input "Enter the first domain name: ~domain.com")
mail_hostname=$(get_input "Enter the hostname ~mail.hostname.com")
admin_pass=$(get_input "Enter the domain admin password:")

# Create the .env file
sudo rm .env
sudo touch .env
echo "FIRST_MAIL_DOMAIN=$domain" >> .env
echo "HOSTNAME=$mail_hostname" >> .env
echo "FIRST_MAIL_DOMAIN_ADMIN_PASSWORD=$admin_pass" >> .env
echo MYSQL_ROOT_PASSWORD=$(openssl rand -base64 9 | tr -d '+/' | head -c 12) >> .env
echo VMAIL_DB_PASSWORD=$(openssl rand -base64 9 | tr -d '+/' | head -c 12) >> .env 
echo VMAIL_DB_ADMIN_PASSWORD=$(openssl rand -base64 9 | tr -d '+/' | head -c 12) >> .env
echo AMAVISD_DB_PASSWORD=$(openssl rand -base64 9 | tr -d '+/' | head -c 12) >> .env
echo MLMMJADMIN_API_TOKEN=$(openssl rand -base64 32) >> .env
echo ROUNDCUBE_DES_KEY=$(openssl rand -base64 24) >> .env

show_message "Configuration complete. .env file has been filled."
######################################################
# Description: set docker setting
# Version: 4.0
######################################################
show_message "Enter a Docker variables:"
# Collect user input for Docker
# Create directoris for store your mail data
file_directory=$(get_input "Enter the folder where your store mail data:")
show_message "creating data directory - $file_directory"

# Create the required directories
sudo mkdir -p /$file_directory/iredmail/data/backup-mysql /$file_directory/iredmail/data/mailboxes /$file_directory/iredmail/data/mlmmj /$file_directory/iredmail/data/mlmmj-archive /$file_directory/iredmail/data/imapsieve_copy /$file_directory/iredmail/data/custom /$file_directory/iredmail/data/ssl /$file_directory/iredmail/data/mysql /$file_directory/iredmail/data/clamav /$file_directory/iredmail/data/sa_rules /$file_directory/iredmail/data/postfix_queue

show_message "Web UI will be running at https://IP:8443 and admin interface at https://IP:8443/iredadmin"
show_message "Docker starting..."
######################################################
######################################################
# --restart unless-stopped
sudo docker run --restart unless-stopped -d --name iRedMail --env-file .env -p 8080:80 -p 8443:443 -p 110:110 -p 995:995 -p 143:143 -p 993:993 -p 25:25 -p 465:465 -p 587:587 -v /$file_directory/iredmail/data/backup-mysql:/var/vmail/backup/mysql -v /$file_directory/iredmail/data/mailboxes:/var/vmail/vmail1 -v /$file_directory/iredmail/data/mlmmj:/var/vmail/mlmmj -v /$file_directory/iredmail/data/mlmmj-archive:/var/vmail/mlmmj-archive -v /$file_directory/iredmail/data/imapsieve_copy:/var/vmail/imapsieve_copy -v /$file_directory/iredmail/data/custom:/opt/iredmail/custom -v /$file_directory/iredmail/data/ssl:/opt/iredmail/ssl -v /$file_directory/iredmail/data/mysql:/var/lib/mysql -v /$file_directory/iredmail/data/clamav:/var/lib/clamav -v /$file_directory/iredmail/data/sa_rules:/var/lib/spamassassin -v /$file_directory/iredmail/data/postfix_queue:/var/spool/postfix iredmail/mariadb:stable 
######################################################
######################################################
docker_status=$(docker container ls  | grep 'iredmail*')
show_message " Container created - $docker_status"

######################################################
# Description: diasable ClamAV
# Version: 4.0
######################################################
ClamAV_off () {
show_message "Disabling ClamAV daemon ( ◣∀◢)ψ "
# get container id via container with awk & grep
container_name=$(docker container ls  | grep 'iredmail*' | awk '{print $1}')
###########################################################################
############### modifyeconfig files #######################################
###########################################################################
# Define an array of lines you want to comment out in /etc/postfix/main.cf
lines_to_comment_main=(
  "content_filter = smtp-amavis:[127.0.0.1]:10024"
  "receive_override_options = no_address_mappings"
  # Add more lines from main.cf as needed
)

# Define an array of lines you want to comment out in /etc/postfix/master.cf
lines_to_comment_master=(
  "-o content_filter=smtp-amavis:[127.0.0.1]:10026"
  # Add more lines from master.cf as needed
)

# Copy the main.cf file from the container to a temporary location on the host
sudo docker cp $container_name:/etc/postfix/main.cf /tmp/main.cf

# Copy the master.cf file from the container to a temporary location on the host
sudo docker cp $container_name:/etc/postfix/master.cf /tmp/master.cf

# Use a loop to comment out each line in main.cf by adding '#' at the beginning
for line in "${lines_to_comment_main[@]}"; do
  sed -i "s|^$line|# $line|" /tmp/main.cf
done

# Use a loop to comment out each line in master.cf by adding '#' at the beginning
for line in "${lines_to_comment_master[@]}"; do
  sed -i "s|^$line|# $line|" /tmp/master.cf
done

# Copy the modified main.cf file back to the container
sudo docker cp /tmp/main.cf $container_name:/etc/postfix/main.cf

# Copy the modified master.cf file back to the container
sudo docker cp /tmp/master.cf $container_name:/etc/postfix/master.cf

show_message "Commented out specified lines in main.cf and master.cf files in the iRedMail/MariaDB container ( ︶｡︶✽) "

sleep 3
###########################################################################
############### stop services #############################################
###########################################################################
stop_clamav_daemon="/etc/init.d/clamav-daemon stop"
stop_clamav_freshclam="/etc/init.d/clamav-freshclam stop"
stop_amavis="sudo /etc/init.d/amavis stop"

# Run the commands inside the container
sudo docker exec -it $container_name bash -c "$stop_clamav_daemon && $stop_clamav_freshclam && $stop_amavis"

show_message "Stopped ClamAV daemon, ClamAV Freshclam, and Amavis in the container ( ︶｡︶✽) "

sleep 3
###########################################################################
############### remove clamav permanently #################################
###########################################################################
remove_clamav_daemon="update-rc.d -f clamav-daemon remove"
remove_clamav_freshclam="update-rc.d -f clamav-freshclam remove"
remove_amavis="update-rc.d -f amavis remove"

# Run the commands inside the container
docker exec -it $container_name bash -c "$remove_clamav_daemon && $remove_clamav_freshclam && $remove_amavis"

show_message "Removed ClamAV daemon, ClamAV Freshclam, and Amavis in the container ( ︶｡︶✽) "
# Restart the container to apply the changes
docker restart $container_name
# Install sucessfull
show_message " your iredmail sucessfully installed ◝(^⌣^)◜"
dialog --clear
sleep 2
exit 0
}

# ClamAV menu
while true; do
    choice=$(dialog --clear --title "Package Management Menu" --menu "Choose an option:" 12 60 4 \
        1 "Disable ClamAV antivirus daemon 😈" \
        2 "Skip and exit ┐( ͡ಠ ʖ̯ ͡ಠ)┌ " 2>&1 >/dev/tty)

    case $choice in
        1)
            ClamAV_off
            ;;
        2)
            # Add your code here instead of exit 0 if needed
            show_message "See your (▼ ᴥ ▼)"
            break
           ;;
        *)
            ;;
    esac
done