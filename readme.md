# Bash Script to Install, Backup & Recover Homeassistant
I created this script to easily install HASS with the following features:
- Latest Home Assistant version
- Including all prerequisites
- Zwave support
- Zwave Aeotec AEON Gen5 USB Stick drivers and dedicated USB port /dev/zwave
- NMAP and Bluetooth tracker support
- Toon Eneco module Support
- Firewall
- Installation of ps4-waker

But this script can also help you to:
- Backup homeassistant configfiles from NAS or local folder
- Recover homeassistant configfiles from NAS or local folder

Please note that this is my first bash script ever. If you have any feedback or suggestions let me know: https://community.home-assistant.io/t/installation-bash-script-almost-fully-automated/4024


Home Assistant is an open source Domotica system with a large community. Check: [Home Assistant](https://homeAssistant.io).

**WARNING!!!**
**This script is tested on RaspBerry PI 3 Model B but using this is at your own risk. Please adjust it to your own needs!!**
**In case you want to be absloutely sure about the outcome, use the manual installation steps your can find [here](https://home-assistant.io/getting-started/installation-raspberry-pi/).**

## Installation
Enter the following command to download it:
```
git clone https://github.com/opdoffer/install-backup-recover-hass.git
```
Start the script:
```
cd install-backup-recover-hass
./inst-bckup-recover-hass.sh
```

## Automated installation
This script will ask for some user input to match your situation. In case you want to automate it to the max please customize the variables at the beginning of this script. 
E.g. use nano to edit it:

```
sudo nano ./inst-bckup-recover-hass.sh
```

## TODO list

- Apache installation + startssl certificaties
- Linux virtual environment. It is now running in pi environment

##Related
[Home Assistant](https://homeAssistant.io).

[Toon python3 module](https://github.com/opdoffer/toon-homeassistant).

[PS4-waker](https://www.npmjs.com/package/ps4-waker).

[OpenZwave](https://github.com/OpenZWave).
