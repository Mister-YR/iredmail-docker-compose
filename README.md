# iredmail-docker-compose
###########################################################################
iredmail-docker 
Folder with compose file with all dependency for IredMail:

# Setup steps:

1) Install all dependency via dependency_setup.sh, script will perform:
   
   2.1 update repos

   2.2 install docker.io & docker-compose

   2.3 install openssl

   2.3 create .env file

   2.4 read user input for IredMail vars and fill .env file

2) Resize swap via gui_swap_setup.sh (Strongly recommended if you have less than 4GB RAM ( ͡° ʖ̯ ͡°))

3) execute docker-compose.yml for install IredMail via docker (sudo docker-compose up -d)
   
7) run clamav_disable.sh, script will disable ClamAV antivirus (Strongly recommended if you have less than 4GB RAM and 2-core CPU  ( ͡° ʖ̯ ͡°))
   
###########################################################################

one-file-gui_project 😊
Single file to install mail service via one script with dialog windows.
