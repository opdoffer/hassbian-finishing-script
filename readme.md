# Bash Script to finish the configuration for HASSBIAN
I created this script to easily to finish the installation of HASSbian with the following features:
- Latest Home Assistant version
- Zwave support
- Zwave Aeotec AEON Gen5 USB Stick drivers and dedicated USB port /dev/zwave
- NMAP tracker support
- Toon Eneco module Support
- Firewall
- Linux virtual environment: home-assistant user.

But this script can also help you to:
- Backup homeassistant configfiles from NAS or local folder
- Recover homeassistant configfiles from NAS or local folder
- Check HASS config
- Update HASS to latest version

Please note that this is my first bash script ever. If you have any feedback or suggestions let me know: https://community.home-assistant.io/t/installation-bash-script-almost-fully-automated/4024


Home Assistant is an open source Domotica system with a large community. Check: [Home Assistant](https://homeAssistant.io).

**WARNING!!!**
**This script is tested on RaspBerry PI 3 Model B with HASSBIAN installed, but using this is at your own risk. Please adjust it to your own needs!!**
**In case you want to be absloutely sure about the outcome, use the manual installation steps your can find [here](https://home-assistant.io/getting-started/installation-raspberry-pi/).**

## Installation
Enter the following command to download it:
```
git clone https://github.com/opdoffer/hassbian-finishing-script.git
```
Start the script:
```
cd hassbian-finishing-script
./inst-hassbian.sh
```

## Automated installation
This script will ask for some user input to match your situation. In case you want to automate it to the max please customize the variables at the beginning of this script. 
E.g. use nano to edit it:

```
sudo nano ./inst-hassbian.sh
```

## TODO list

- Apache installation + startssl certificaties

##Related
[Home Assistant](https://homeAssistant.io).

[Toon python3 module](https://github.com/opdoffer/toon-homeassistant).

[OpenZwave](https://github.com/OpenZWave).
