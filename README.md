# Warpi installation

## Preparation
1. Download Kali Raspberry [Image](https://www.kali.org/get-kali/#kali-arm)

2. Download Imager from [here](https://www.raspberrypi.com/software/)

3. Copy ssh & Wpa_supplicant to the boot section

## First boot
ssh kali@[IP-Ardress]

change current password (kali): `passwd`

`sudo dpkg-reconfigure keyboard-configuration && sudo timedatectl set-timezone Europe/Berlin`

## First setup steps
`wget https://raw.githubusercontent.com/galli3r/warpi/main/warpi_setup.sh`

`sudo chmod +x warpi_setup.sh`

## Kali Raspberry Pi Swap setup
> https://kalitut.com/raspberry-pi-swapping/

`sudo apt install dphys-swapfile`

`sudo nano /etc/dphys-swapfile`
```
# /etc/dphys-swapfile - user settings for dphys-swapfile package
# author Neil Franklin, last modification 2010.05.05
# copyright ETH Zuerich Physics Departement
#   use under either modified/non-advertising BSD or GPL license

# this file is sourced with . so full normal sh syntax applies

# the default settings are added as commented out CONF_*=* lines


# where we want the swapfile to be, this is the default
#CONF_SWAPFILE=/var/swap

# set size to absolute value, leaving empty (default) then uses computed value
#   you most likely don't want this, unless you have an special disk situation
#CONF_SWAPSIZE=

# set size to computed value, this times RAM size, dynamically adapts,
#   guarantees that there is enough swap without wasting disk space on excess
CONF_SWAPFACTOR=2

# restrict size (computed and absolute!) to maximally this limit
#   can be set to empty for no limit, but beware of filled partitions!
#   this is/was a (outdated?) 32bit kernel limit (in MBytes), do not overrun it
#   but is also sensible on 64bit to prevent filling /var or even / partition
#CONF_MAXSWAP=2048

```

`sudo systemctl enable dphys-swapfile`

## Activate I2C / UART
`sudo nano /etc/modules`
```
#Paste on the end:
i2c-bcm2708
i2c-dev
rtc-ds1307
```

`sudo nano /boot/config.txt`<br>
```
#Paste
dtparam=i2c1=on
dtparam=i2c_arm=on
enable_uart=1
dtoverlay=i2c-rtc,ds3231
```

`sudo nano /boot/commandline.txt`<br>
```
#remove all serial parts<br>
dwc_otg.fiq_fix_enable=2 root=PARTUUID=ed889dad-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait net.ifnames=0
```

## Activate the RTC / GPS
for GPS GPSD is used<br>
in my case it's USB device:<br>
Bus 001 Device 003: ID 067b:23a3 Prolific Technology, Inc. ATEN Serial Bridge

`sudo nano /etc/default/gpsd`

```
# Default settings for the gpsd init script and the hotplug wrapper.

# Start the gpsd daemon automatically at boot time
START_DAEMON="false"

# Use USB hotplugging to add new USB devices automatically to the daemon
USBAUTO="true"

# Devices gpsd should collect to at boot time.
# They need to be read/writeable, either by user gpsd or the group dialout.
DEVICES="/dev/ttyUSB0"

# Other options you want to pass to gpsd
GPSD_OPTIONS="-n -G -b"
#GPSD_SOCKET="/var/run/gpsd.sock"
#end of file gpsd
```

if you use a RTC => set this once:<br>
`hwclock -w`

## WIFI setup
> https://forums.raspberrypi.com/viewtopic.php?f=36&t=198946

`sudo ln -nfs /dev/null /etc/systemd/network/99-default.link`<br>
`sudo nano /etc/udev/rules.d/72-wlan-geo-dependent.rules`<br>
```
#
# +---------------+
# | wlan1 | wlan2 |
# +-------+-------+
# | wlan3 | wlan4 |
# +---------------+ (RPI USB ports with position dependent device names for up to 4 optional wifi dongles)
#
# | wlan0 | (onboard wifi)
#
ACTION=="add", SUBSYSTEM=="net", SUBSYSTEMS=="sdio", KERNELS=="mmc1:0001:1", NAME="wlan0"
ACTION=="add", SUBSYSTEM=="net", SUBSYSTEMS=="usb",  KERNELS=="1-1.2",       NAME="wlan1"
ACTION=="add", SUBSYSTEM=="net", SUBSYSTEMS=="usb",  KERNELS=="1-1.4",       NAME="wlan2"
ACTION=="add", SUBSYSTEM=="net", SUBSYSTEMS=="usb",  KERNELS=="1-1.3",       NAME="wlan3"
ACTION=="add", SUBSYSTEM=="net", SUBSYSTEMS=="usb",  KERNELS=="1-1.5",       NAME="wlan4"
```
## the OLED script to boot and 64 bit hacks
> https://github.com/designer2k2/warpi/blob/master/warpigui.py

cp arial.ttf and Minecraftia.ttf

> https://www.dexterindustries.com/howto/run-a-program-on-your-raspberry-pi-at-startup/#systemd

`sudo nano /lib/systemd/system/warpi.service`

```
[Unit]
 Description=Warpi Service
 After=multi-user.target

[Service]
 Type=idle
 ExecStart=/usr/bin/python /home/kali/warpigui.py

[Install]
 WantedBy=multi-user.target
```

`ExecStart=/usr/bin/python /home/kali/warpigui.py > /home/kali/warpi.log 2>&1`

`sudo chmod 644 /lib/systemd/system/warpi.service`

`sudo systemctl daemon-reload`

`sudo systemctl enable warpi.service`

`sudo reboot`

## Kismet config
copy the kismet_site.conf to /etc/kismet, modify the wlan and bluetooth sources.

## mount the USB stick
> https://pimylifeup.com/raspberry-pi-mount-usb-drive/

find out the right Volume from the USB Stick
`ls /dev/sd*`

`sudo blkid /dev/sda1`
/dev/sda1: UUID="2xxx-6xxx" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="1d141651-01"

`sudo mkdir -p /media/usb`

`sudo chown -R kali:kali /media/usb`

`sudo nano /etc/fstab`
```
UUID=2xxx-6xxx /media/usb vfat defaults,auto,users,rw,nofail,noatime 0 0
```

`sudo reboot`



