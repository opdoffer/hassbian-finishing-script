#!/bin/bash
# Fresh install, backup or restore HASS on a raspberry pi 3 Model B

## ----------------------------------
# Define custom variables
# ----------------------------------
tzone="your_time_zone" #Enter your timezone
host_domain="your host and domainname" #Please enter your host and domainname for accessing hass from the internet: e.g. <hass.yourdomain.com>
nas_share="//192.168.x.x/share" #Please enter the ip-aders of your NAS and backupshare for backing up your config and for recovery
loc_bck="/foldername" #Please enter the local backup folder for your hass config files. Keep this default when using NAS_SHARE for backup
cert_loc="/certs_default" #Please enter the folder where the startssl are located. When restoring from NAS note that backup share is mounted to /media/hass-nas/




## ----------------------------------
# Colors - do not change below
# ----------------------------------
RED='\033[0;31m \e[1m'
NC='\033[0m' # No Color
DATE=`date +%Y-%m-%d`


# ----------------------------------------------
# Functions
# ----------------------------------------------

hassinst (){
printf "\033c"
echo -e "${RED}Really want to start new install of HASS?${NC}\n"
read -p "Press [ENTER] to continue or CTRL-C to abort..."
if [[ $tzone = your_time_zone ]] ; then
   echo -e "${RED}The timezonevariable is still default value: $tzone.${NC}\n"
   echo "The system current timezone information is shown below:"
   timedatectl
   echo " "
   echo " "
   read -p "Do you want to change this for now? [y/n]" answer0
		if [[ $answer0 = y ]] ; then
			echo "Please enter zone e.g.: America/New_York" 
			read tzone
			sudo timedatectl set-timezone $tzone
			echo "system updated with $tzone as timezone"
		fi
else
  	read tzone
	sudo cp /usr/share/zoneinfo/Europe/$tzone /etc/localtime
	echo "system updated with $tzone as timezone"
fi
#commands for updating system
printf "\033c"
echo -e "${RED}About to Update system. This might take a long time (apt-get upgrade).${NC}\n"
read -p "Press [ENTER] to continue or CTRL-C to abort..."
sudo apt-get update -y
sudo apt-get upgrade -y
#Install Python prereqs
sudo apt-get install python3 python3-venv python3-pip -y
#Install commands for HASS latest version
sudo pip3 install homeassistant
#Let HASS create default config on first time start
echo " "
echo " "
echo " "
echo -e "${RED}Hass will be started for the first time to create default config folder/files. Let it run for 2 minutes and press CTRL_C${NC}\n"
read -p "Press [ENTER] to continue or CTRL-C to abort..."
hass --open-ui
#Configure your system to autostart HASS
sudo su -c 'cat <<EOF > /etc/systemd/system/home-assistant@pi.service
[Unit]
Description=Home Assistant
After=network.target

[Service]
Type=simple
User=pi
ExecStart=/usr/local/bin/hass
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl --system daemon-reload
sudo systemctl enable home-assistant@pi
sudo systemctl start home-assistant@pi
echo " "
echo " "
read -p "Hass install procedure finished and made it start on boot. Please [ENTER] to continue..."
}

hassinst_zwave (){
hassinst
#install commands for zwave Aeotec
sudo apt-get install cython3 libudev-dev python3-sphinx python3-setuptools -y
sudo pip3 install --upgrade cython
git clone https://github.com/OpenZWave/python-openzwave.git
cd python-openzwave
git checkout python3
PYTHON_EXEC=$(which python3) make build
sudo PYTHON_EXEC=$(which python3) make install
sudo su -c 'cat <<EOF > /etc/udev/rules.d/99-usb-serial.rules
SUBSYSTEM=="tty", ACTION=="add", ATTRS{idVendor}=="0658", ATTRS{idProduct}=="0200", SYMLINK+="zwave"
EOF'
echo -e "${RED}Your zwave controller USB stick is configured. You can use this in your hass-config as /dev/zwave${NC}\n"
read -p "Please [ENTER] to return to menu..."
}


hassinst_zwave_nmap (){
hassinst_zwave
#install commands for nmap
sudo apt-get install net-tools nmap -y
sudo apt-get install bluetooth libbluetooth-dev -y
sudo apt-get install npm
sudo npm install ps4-waker -g
read -p "Finished installing NMAP and Bluetooth. Please [ENTER] to continue..."
}

hassinst_zwave_nmap_recoverhass (){
hassinst_zwave_nmap
mounting_nas
recoverhass
}

recoverhass(){
#Recover commands HASS files from NAS
read -p "Do you want to recover from NAS [y/n]" answer1
if [[ $answer1 = y ]] ; then
	mounting_nas
	echo "The following backup folders where found:"
	sudo ls /media/hass-nas/
	echo "Please provide date (foldername) where you want to recover from:"
	read rest_nas
	sudo rsync --progress /media/hass-nas/$rest_nas/* /home/pi/.homeassistant/
	sudo rsync --progress /media/hass-nas/$rest_nas/scripts/* /home/pi/.homeassistant/scripts
	read -p "Please [ENTER] to return to menu..."	
else
   	echo "The restorefolder is still default value: $loc_bck."
   	echo "Please enter the folder where you want to restore from."
   	read loc_fld_rest
	sudo rsync --progress $loc_lfd_rest/* /home/pi/.homeassistant/
	sudo rsync --progress $loc_lfd_rest/scripts/* /home/pi/.homeassistant/scripts
fi
read -p "End of restore. Please check above for errors. Press [ENTER] to continue..."
}

hassinst_zwave_nmap_recover_toon(){
hassinst_zwave_nmap_recoverhass
git clone https://github.com/opdoffer/toon-homeassistant.git
cd toon-homeassistant
sudo python3 toon.py install
sudo mkdir /home/pi/.homeassistant/scripts
sudo cp /toon-homeassistant/toonclient.py /home/pi/.homeassistant/scripts
#sudo python3 /media/hass-nas/homeassistant/scripts/toon.py install
read -p "Please [ENTER] to continue..."
}

apacheinst (){
#Install commands for apache
read -p "About to install Apache2. Please press CTRL-C to abort or [ENTER] to continue..."
sudo apt-get install apache2 -y
sudo a2enmod ssl
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite
sudo a2enmod headers
#Recover commands for startsll certificates
read -p "Please press CTRL-C abort if you DO NOT want to restore ssl certificates"
if [ $cert_loc="/certs_default" ]; then
   echo "The location of your certs is still default value: $cert_loc."
   read -p "Do you want to specify a location now? [y/n]" answer3
	if [[ $answer3 = y ]] ; then
	   read -p "Please enter the full path of the startssl certificates:"
	   read cert_loc_man
	   read -p "Please your domainname for your start ssl certificates"
	   read host_domain_man
	   sudo \cp -rf $cert_loc_man/2_$host_domain_man_bundle.crt /etc/ssl/private/2_$host_domain_man.crt
	   sudo \cp -rf $cert_loc_man/1_root_bundle.crt /etc/ssl/certs/1_root_bundle.crt
	   sudo \cp -rf $cert_loc_man/csrkeystartssl.key /etc/ssl/private/hass.key

#Below needs changing to variables
		sudo \cp -rf /media/hass-nas/hass/apache2/apache2.conf /etc/apache2/
   		sudo \cp -vr /media/hass-nas/hass/apache2/sites-available/* /etc/apache2/sites-available
   		sudo \cp -vr /media/hass-nas/hass/apache2/sites-enabled/* /etc/apache2/sites-enabled
	   	sudo a2enconf $host_domain_man
	fi
else
   read -p "Please enter username to connect to NAS"
   read nas_usr
   read -p "Please enter password to connect to NAS"
   read nas_psw
   sudo \cp -rf /media/hass-nas$cert_loc/2_$host_domain_bundle.crt /etc/ssl/private/2_$host_domain.crt
   sudo \cp -rf $cert_loc_man/1_root_bundle.crt /etc/ssl/certs/1_root_bundle.crt
   sudo \cp -rf /media/hass-nas$cert_loc/csrkeystartssl.key /etc/ssl/private/hass.key

#Below needs changing to variables
   sudo \cp -rf /media/hass-nas/hass/apache2/apache2.conf /etc/apache2/
   sudo \cp -vr /media/hass-nas/hass/apache2/sites-available/* /etc/apache2/sites-available
   sudo \cp -vr /media/hass-nas/hass/apache2/sites-enabled/* /etc/apache2/sites-enabled
   #enable your domainname in apache2
   sudo a2enconf $host_domain
   read -p "Please [ENTER] to continue..."
fi
}

firewallinst (){
#Install en config commands firewall
echo -e "${RED}This will enable a simple firewall and opens ports: 22, 80, 443 and 8123.${NC}\n"
read -p "Please [ENTER] to continue..."
sudo apt-get install ufw
sudo ufw enable
sudo ufw allow proto tcp from any to any port 22,80,443,8123
read -p "Please [ENTER] to return to menu..."
}

stat_ip_addr (){
#Change to static ip-address
echo "Please enter the ip-address you want to this raspberry pi 3 to be accessed via eth0"
read st_ipaddr
echo "Please enter the ip-address of your router"
read routr
echo "You entered the following"
echo "$st_ipaddr as your Ip-address"
echo "$routr as your routers ip-address"

sudo tee -a /etc/dhcpcd.conf >> /dev/null <<EOF

interface eth0

static ip_address=$st_ipaddr/24
static routers=$routr
static domain_name_servers=8.8.8.8 8.8.4.4

EOF
finish_reboot
}


all_above (){
hassinst_zwave_nmap_recover_toon
apacheinst
firewallinst
finish_reboot
}

hass_backup (){
#Backup commands HASS files from NAS
read -p "Do you want to backup to NAS [y/n]" answer2
if [[ $answer2 = y ]] ; then
	mounting_nas
	sudo mkdir /media/hass-nas/$DATE
	sudo rsync -r --progress /home/pi/.homeassistant/* /media/hass-nas/$DATE	
else
	if [ $loc_bck = "/foldername" ]; then
   		echo "The backupfolder is still default value: $loc_bck."
   		echo "Please enter the folder where you want to backup to."
   		read loc_fld_bck
   		sudo mkdir $loc_fld_bck
   		sudo 	mkdir $loc_fld_bck/$DATE
		sudo rsync --progress /home/pi/.homeassistant/* $loc_lfd_bck/
		sudo rsync --progress /home/pi/.homeassistant/scripts/* $loc_lfd_bck/scripts
	else
		sudo mkdir $loc_bck
		sudo rsync --progress /home/pi/.homeassistant/* $loc_bck/
		sudo rsync --progress /home/pi/.homeassistant/scripts/* $loc_bck/scripts
	fi
fi
read -p "End of backup script. Please check above for errors. Press [ENTER] continue..."
}

mounting_nas (){
#mounting commands NAS
if [[ $nas_share = //192.168.x.x/share ]] ; then
	echo -e "${RED}The nas_share is still default value: $nas_share.${NC}\n"
	echo "To continue we need more information:"
	echo "Please enter username to connect to NAS, (case sensitive)" 
	read nas_usr
	echo "Please enter password to connect to NAS, (case sensitive)" 
	read nas_psw
	echo "Please enter ipaddress of your NAS"
	read nas_ip
	echo "Please enter sharename on your NAS, (case sensitive)"
	read ns_share
	sudo mkdir /media/hass-nas
	sudo mount -t cifs -o username=$nas_usr,password=$nas_psw //$nas_ip/$ns_share/ /media/hass-nas/
else
	echo "Please enter username to connect to NAS, (case sensitive)"
	read nas_usr
	echo "Please enter password to connect to NAS, (case sensitive)"
	read nas_psw
	sudo mkdir /media/hass-nas
	sudo mount -t cifs -o username=$nas_usr,password=$nas_psw $nas_share/ /media/hass-nas/	
fi
}

finish_reboot (){
#Reboot command after install
read -p "Please enter to finish and reboot the system"
sudo shutdown -r 0
}

wifi_setup(){
printf "\033c"
	echo "Please enter the SSID of your WIFI"
	read ssid_wifi
	echo "Please enter WIFI password"
	read passwd_wifi

sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf >> /dev/null <<EOF

network={
    ssid="$ssid_wifi"
    psk="$passwd_wifi"
}
EOF
}

check_config(){
hass --script check_config
read -p "Press [ENTER] to return to menu..."
} 
 
update_has_version(){
echo "We always make a backup of the config before upgrading HASS. Pleae read the HASS release notes before continuing."
read -p "Did you made a backup of HASS [y/n]" answer4
if [[ $answer4 = y ]] ; then
	sudo pip3 install --upgrade homeassistant
	hass --script check_config
	read -p "Config checked. Check for errors in the lines above. Press [ENTER] to continue..."
	sudo service home-assistant@pi restart
else
	hass_backup
	sudo pip3 install --upgrade homeassistant
	hass --script check_config
	read -p "Config checked. Check for errors in the lines above. Press [ENTER] to continue..."
	sudo service home-assistant@pi restart
fi

}  
 
 
# function to display menus
show_menus() {
	clear
	echo -e "This scripts is build and tested on a ${RED}RaspBerry Pi 3 Model B ${NC}\n"
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo " 1. Install HASS: clean install default config."
	echo " 2. Install HASS + Zwave support Aeotec Aeon Gen 5 USB Stick"
	echo " 3. All above + NMAP + Bluetooth tracker support + PS4-waker"
	echo " 4. All above + Recover HASS configs from Backup"
	echo " 5. All above + Eneco Toon Support"
	echo " 6. Install Apache2 + StartSSLCertificates (do not use this: still under dev.)"
	echo " 7. Enable firewall"
	echo " 8. Set static ip-address (do not use, doesn't work yet!!!)"
	echo " 9. All above"
	echo "10. Backup HASS to NAS or local folder"
	echo "11. Backup apache to NAS"
	echo "12. Recover Hass config files from NAS or local folder"
	echo "13. Wifi Setup (do not use, doesn't work yet!!!)"
	echo "14. Check HASS config"
	echo "15. Update HASS to latest version"
	echo "16. Quit"
}
# read input from the keyboard and take a action
read_options(){
	local choice
	read -p "Enter choice [ 1 - 16] " choice
	case $choice in
		1) hassinst ;;
		2) hassinst_zwave ;;
		3) hassinst_zwave_nmap ;;
		4) hassinst_zwave_nmap_recover ;;
		5) hassinst_zwave_nmap_recover_toon ;;
		6) apacheinst ;;
		7) firewallinst ;;
		8) stat_ip_addr ;;
		9) all_above ;;
		10) hass_backup ;;
		11) apache_bck ;;
		12) recoverhass ;;
		13) wifi_setup ;;
		14) check_config ;;
		15) update_has_version ;;
		16) exit 0;;
		*) echo -e "${RED}Error...${NC}" && sleep 2
	esac
}
 

# -----------------------------------
# Main logic - infinite loop
# ------------------------------------
while true
do
	show_menus
	read_options
done


