#!/bin/bash -e

source ../commands

##lirc
log "start installing lirc"

# download source from github
if [ ! -e files/python3-lirc_1.2.1-1_armhf.deb ]; then
	wget "https://github.com/tompreston/python-lirc/releases/download/v1.2.1/python3-lirc_1.2.1-1_armhf.deb" -P files/
fi

# copy file
cp files/python3-lirc_1.2.1-1_armhf.deb "${ROOTFS_DIR}/home/pi/_installations/python3-lirc_1.2.1-1_armhf.deb"

on_chroot << EOF
	dpkg -i "/home/pi/_installations/python3-lirc_1.2.1-1_armhf.deb"
EOF

# append lirc config to /etc/modules
if_no_text_then_add "${ROOTFS_DIR}/etc/modules" "lirc_rpi gpio_in_pin=4" "
lirc_dev
lirc_rpi gpio_in_pin=4" 

# append another config to /etc/lirc/hardware.conf
if_no_text_then_add "${ROOTFS_DIR}/etc/lirc/hardware.conf" 'DEVICE="/dev/lirc0"' '
# Arguments which will be used when launching lircd
LIRCD_ARGS="--uinput --listen"

# Dont start lircmd even if there seems to be a good config file
# START_LIRCMD=false

# Dont start irexec, even if a good config file seems to exist.
# START_IREXEC=false

# Try to load appropriate kernel modules
LOAD_MODULES=true

# Run "lircd --driver=help" for a list of supported drivers.
DRIVER="default"

# usually /dev/lirc0 is the correct setting for systems using udev
DEVICE="/dev/lirc0"
MODULES="lirc_rpi"

# Default configuration files for your hardware if any
LIRCD_CONF=""
LIRCMD_CONF=""'

# add lirc map gpio pin in /boot/config.txt
if_no_text_then_add "${ROOTFS_DIR}/boot/config.txt" "dtoverlay=lirc-rpi:gpio_in_pin=4" "
# lirc
dtoverlay=lirc-rpi:gpio_in_pin=4"

# append lirc options
if_no_text_then_add "${ROOTFS_DIR}/boot/config.txt" "device    = /dev/lirc0" '
driver    = default
device    = /dev/lirc0'

# IR keys
if [ ! -e files/lirc_configs.zip ]; then
	wget "https://www.dropbox.com/s/08xttu8vaad2qn0/lirc_configs.zip" -P files/
    unzip files/lirc_configs.zip -d files/lirc_configs
fi

# copy settings to place
cp files/lirc_configs/lircd.conf "${ROOTFS_DIR}/etc/lirc/lircd.conf"
cp files/lirc_configs/lircrc "${ROOTFS_DIR}/home/pi/.lircrc"
cp files/lirc_configs/lircrc "${ROOTFS_DIR}/etc/lirc/lircrc"

# change files permission
on_chroot << EOF
	chmod 777 "/home/pi/.lircrc"
	chmod 777 "/etc/lirc/lircrc"
	chmod 777 "/etc/lirc/lircd.conf"
EOF

###########################################################################################






