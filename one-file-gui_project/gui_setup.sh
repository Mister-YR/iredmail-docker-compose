#!/bin/bash
######################################################
# Description: one-file-gui_setup.sh
# Author: Mister-YR
# Link: https://github.com/Mister-YR/iredmail-docker-compose.git
# Version: 4.0
######################################################
sudo apt-get install dialog -y
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

# Extend swap file to 4gb
$desired_swap_size_mb=4096
show_message "swap size must been 4 gb or greather"
# Check if a swap file already exists
# Specify the desired swap file size in megabytes (4GB = 4096MB)
desired_swap_size_mb=4096

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
        show_message "Swap file extended to $desired_swap_size_mb MB."
    else
        show_message "Swap file is already at or larger than the desired size."
    fi
else
    show_message "No swap file found. Creating a new swap file..."
    sudo dd if=/dev/zero of=/swapfile bs=1M count="$desired_swap_size_mb" status=progress
    sudo chmod 600 /swapfile  # Secure permissions
    sudo mkswap /swapfile  # Create swap space
    sudo swapon /swapfile  # Turn on swap
    show_message "Swap file created with size $desired_swap_size_mb MB."
fi

# Verify the current swap size
free -h
# Verify the current swap size
swap_check=$(free -h)
show_message "$swap_check"
######################################################
# Description: install all denendency
# Version: 4.0
######################################################

# Update package manager repositories
show_message "install all dependency"
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
sudo rm .env
sudo touch .env
echo "FIRST_MAIL_DOMAIN=$domain" >> .env
echo "HOSTNAME=$mail_hostname" >> .env
echo "FIRST_MAIL_DOMAIN_ADMIN_PASSWORD=$admin_pass" >> .env
echo "MLMMJADMIN_API_TOKEN=$(openssl rand -base64 32)" >> .env
echo "ROUNDCUBE_DES_KEY=$(openssl rand -base64 24)" >> .env

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
#docker run -d --name iRedMail --env-file /docker-compose/iredmail/iredmail-docker.conf -p 8080:80 -p 8443:443 -p 110:110 -p 995:995 -p 143:143 -p 993:993 -p 25:25 -p 465:465 -p 587:587 -v /docker-compose/iredmail/data/backup-mysql:/var/vmail/backup/mysql -v /docker-compose/iredmail/data/mailboxes:/var/vmail/vmail1 -v /docker-compose/iredmail/data/mlmmj:/var/vmail/mlmmj -v /docker-compose/iredmail/data/mlmmj-archive:/var/vmail/mlmmj-archive -v /docker-compose/iredmail/data/imapsieve_copy:/var/vmail/imapsieve_copy -v /docker-compose/iredmail/data/custom:/opt/iredmail/custom -v /docker-compose/iredmail/data/ssl:/opt/iredmail/ssl -v /docker-compose/iredmail/data/mysql:/var/lib/mysql -v /docker-compose/iredmail/data/clamav:/var/lib/clamav -v /docker-compose/iredmail/data/sa_rules:/var/lib/spamassassin -v /docker-compose/iredmail/data/postfix_queue:/var/spool/postfix iredmail/mariadb:stable
docker run -d --name iRedMail --env-file .env -p 8080:80 -p 8443:443 -p 110:110 -p 995:995 -p 143:143 -p 993:993 -p 25:25 -p 465:465 -p 587:587 -v /$file_directory/iredmail/data/backup-mysql:/var/vmail/backup/mysql -v /$file_directory/iredmail/data/mailboxes:/var/vmail/vmail1 -v /$file_directory/iredmail/data/mlmmj:/var/vmail/mlmmj -v /$file_directory/iredmail/data/mlmmj-archive:/var/vmail/mlmmj-archive -v /$file_directory/iredmail/data/imapsieve_copy:/var/vmail/imapsieve_copy -v /$file_directory/iredmail/data/custom:/opt/iredmail/custom -v /$file_directory/iredmail/data/ssl:/opt/iredmail/ssl -v /$file_directory/iredmail/data/mysql:/var/lib/mysql -v /$file_directory/iredmail/data/clamav:/var/lib/clamav -v /$file_directory/iredmail/data/sa_rules:/var/lib/spamassassin -v /$file_directory/iredmail/data/postfix_queue:/var/spool/postfix iredmail/mariadb:stable 
######################################################
######################################################
docker_status=$(docker container ls  | grep 'iredmail*')
show_message " container created - $docker_status"

######################################################
# Description: diasable ClamAV
# Version: 4.0
###################################################### 
show_message "Disable ClamAV daemon :devilish:"
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

show_message "Commented out specified lines in main.cf and master.cf files in the iRedMail/MariaDB container"

sleep 5
###########################################################################
############### stop services #############################################
###########################################################################
stop_clamav_daemon="/etc/init.d/clamav-daemon stop"
stop_clamav_freshclam="/etc/init.d/clamav-freshclam stop"
stop_amavis="sudo /etc/init.d/amavis stop"

# Run the commands inside the container
sudo docker exec -it $container_name bash -c "$stop_clamav_daemon && $stop_clamav_freshclam && $stop_amavis"

show_message "Stopped ClamAV daemon, ClamAV Freshclam, and Amavis in the container"

sleep 5
###########################################################################
############### remove clamav permanently #################################
###########################################################################
remove_clamav_daemon="update-rc.d -f clamav-daemon remove"
remove_clamav_freshclam="update-rc.d -f clamav-freshclam remove"
remove_amavis="update-rc.d -f amavis remove"

# Run the commands inside the container
docker exec -it $container_name bash -c "$remove_clamav_daemon && $remove_clamav_freshclam && $remove_amavis"

echo "removed ClamAV daemon, ClamAV Freshclam, and Amavis in the container"

sleep 5
# # Restart the container to apply the changes
docker restart $container_name
# end message
show_message " your iredmail sucessfully installed"