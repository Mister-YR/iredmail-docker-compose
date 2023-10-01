#!/bin/bash
# Update the package manager repositories (apt-get for Ubuntu/Debian)
sudo apt-get update
# Install Docker
sudo apt-get install -y docker.io
# Install Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Install OpenSSL
sudo apt-get install -y openssl
echo "All dependency installation complete."
###############################################################
touch .env
echo "enter fisrst domain name :"
read -p domain
echo "enter hostamame: for example ~ mail.your_shiny_domail.com :"
read -p mail_hostname
echo "enter domnain admin password :"
read -p admin_pass
echo "your can find your MLMMJADMIN_API_TOKEN & ROUNDCUBE_DES_KEY in .env file "
###############################################################
echo FIRST_MAIL_DOMAIN=$domain >> .env
echo HOSTNAME=$mail_hostname >> .env
echo FIRST_MAIL_DOMAIN_ADMIN_PASSWORD=$admin_pass >> .env
echo MYSQL_ROOT_PASSWORD=$(openssl rand -base64 9 | tr -d '+/' | head -c 12) >> .env
echo VMAIL_DB_PASSWORD=$(openssl rand -base64 9 | tr -d '+/' | head -c 12) >> .env 
echo VMAIL_DB_ADMIN_PASSWORD=$(openssl rand -base64 9 | tr -d '+/' | head -c 12) >> .env
echo AMAVISD_DB_PASSWORD=$(openssl rand -base64 9 | tr -d '+/' | head -c 12) >> .env
echo MLMMJADMIN_API_TOKEN=$(openssl rand -base64 32) >> .env
echo ROUNDCUBE_DES_KEY=$(openssl rand -base64 24) >> .env