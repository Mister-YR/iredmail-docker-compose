# MAX swap file size in raspbian =2Gb, and current value =100mb:
# 1 - MAX swap size ~ /sbin/dphys-swapfile
# 2 - CURRENT swap size ~ /etc/dphys-swapfile
#!/bin/bash
echo "In raspbian default MAX max sawp size = 2048 |-_-|"
echo "enter new swap MAX file size in BIN format:"
read -p "~ for example 8196 =" swap_size_max
echo "MAX swap size will be - $swap_size_max mb"
#write new MAX swap size
sudo sed -i 's/CONF_MAXSWAP=2048/CONF_MAXSWAP='$swap_size_max'/' /sbin/dphys-swapfile
sleep 10s
# stop using swap
echo "Stop using swap file"
sudo dphys-swapfile swapoff
#modify current swap file size 
echo "enter new swap CURRENT file size in BIN format:"
read -p "~ for example 8196 =" swap_size_current
#write new CURRENT swap size
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE='$swap_size_current'/' /etc/dphys-swapfile
# delete & reinicialize swap
sleep 10s
sudo dphys-swapfile setup
#reboot section
read -p "Press any key to reboot server... " -n1 -s
sleep 30s
sudo reboot