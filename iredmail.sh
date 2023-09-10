#!/bin/bash
# get container id via container with awk & grep
container_name=$(docker container ls  | grep 'iredmail*' | awk '{print $1}')
#######################################################################################
############### modify econfig files ##################################################
#######################################################################################
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
docker cp $container_name:/etc/postfix/main.cf /tmp/main.cf

# Copy the master.cf file from the container to a temporary location on the host
docker cp $container_name:/etc/postfix/master.cf /tmp/master.cf

# Use a loop to comment out each line in main.cf by adding '#' at the beginning
for line in "${lines_to_comment_main[@]}"; do
  sed -i "s|^$line|# $line|" /tmp/main.cf
done

# Use a loop to comment out each line in master.cf by adding '#' at the beginning
for line in "${lines_to_comment_master[@]}"; do
  sed -i "s|^$line|# $line|" /tmp/master.cf
done

# Copy the modified main.cf file back to the container
docker cp /tmp/main.cf $container_name:/etc/postfix/main.cf

# Copy the modified master.cf file back to the container
docker cp /tmp/master.cf $container_name:/etc/postfix/master.cf

echo "Commented out specified lines in main.cf and master.cf files in the iRedMail/MariaDB container"

sleep 15
#######################################################################################
############### stop services #########################################################
#######################################################################################
stop_clamav_daemon="/etc/init.d/clamav-daemon stop"
stop_clamav_freshclam="/etc/init.d/clamav-freshclam stop"
stop_amavis="sudo /etc/init.d/amavis stop"

# Run the commands inside the container
docker exec -it $container_name bash -c "$stop_clamav_daemon && $stop_clamav_freshclam && $stop_amavis"

echo "Stopped ClamAV daemon, ClamAV Freshclam, and Amavis in the container"

sleep 15
#######################################################################################
############### remove clamav permanently #############################################
#######################################################################################
remove_clamav_daemon="update-rc.d -f clamav-daemon remove"
remove_clamav_freshclam="update-rc.d -f clamav-freshclam remove"
remove_amavis="update-rc.d -f amavis remove"

# Run the commands inside the container
docker exec -it $container_name bash -c "$remove_clamav_daemon && $remove_clamav_freshclam && $remove_amavis"

echo "removed ClamAV daemon, ClamAV Freshclam, and Amavis in the container"

sleep 15
# # Restart the container to apply the changes
docker restart $container_name


