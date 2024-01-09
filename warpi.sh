#!/bin/bash
# setup some needed parts for fun raspi
echo "Starte installationen ..."
sleep10
apt update
echo "Zeitzone einstellen ..."
timedatectl set-timezone Europe/Berlin
sleep10
echo "benötigte Programme installieren"
#sudo apt install xrdp
apt -y install kismet
apt -y install python3-smbus
apt -y install i2c-tools
apt -y install gpsd gpsd-clients
apt -y install realtek-rtl88xxau-dkms
apt -y install ntfs-3g
apt -y install exfat-fuse
apt -y install python3-pip
echo "remove large not needed programs"
apt -y remove metasploit-framework firefox-esr exploitdb powershell-empire
apt -y autoremove
echo "upgrade all to have the latest and greatest"
apt -y upgrade
