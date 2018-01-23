#!/bin/bash -e

source ../commands

#Alacarte fixes
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share/applications"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share/desktop-directories"

#Network config
if_no_text_then_add "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf" '\"AIMLAB_2.4G\"' "
ap_scan=1

network={
    ssid=\"<x>\"
    psk=\"<y>\"
}"

on_chroot << EOF
    systemctl enable wpa_supplicant.service
EOF

#Screen rotation (comment these lines if dont wanna rotate screen)
if_no_text_then_add "${ROOTFS_DIR}/boot/config.txt" "display_rotate=2" "
### Custom Settings
# display
hdmi_group=2
hdmi_mode=87
hdmi_cvt 800 480 60 6 0 0 0
#display_rotate=2"

#Proxy (comment these lines if dont want proxy settings)
if_no_text_then_add "${ROOTFS_DIR}/etc/apt/apt.conf.d/10proxy" "Acquire::http::proxy" '
Acquire::http::proxy "http://<x>:<y>@proxy-sa.mahidol:8080/";'

#i2c
if_no_text_then_add "${ROOTFS_DIR}/etc/modules" "snd-bcm2835" "
i2c-dev
snd-bcm2835"

##tty serial port (need to run manually)
# gpio mode 15 ALT0; gpio mode 16 ALT0

# add uart config
if_no_text_then_add "${ROOTFS_DIR}/boot/config.txt" "#core_freq=250" '
# Set uart clock
enable_uart=1
#init_uart_clock=16000000
#sudo stty -F /dev/ttyAMA0 1000000

# Workaround for uart on RPi3
#core_freq=250'

##Nodejs
if [ ! -e "${ROOTFS_DIR}/usr/bin/node" ]; then
    on_chroot << EOF
    curl -sL https://deb.nodesource.com/setup_8.x | bash -
    apt-get install -y nodejs
EOF
fi

##Go
if [ ! -e files/go1.9.2.linux-armv6l.tar.gz ]; then
	wget "https://storage.googleapis.com/golang/go1.9.2.linux-armv6l.tar.gz" -P files/
fi

# extract file
tar -C "${ROOTFS_DIR}/usr/local" -xzf files/go1.9.2.linux-armv6l.tar.gz

# add to path
if_no_text_then_add "${ROOTFS_DIR}/home/pi/.bashrc" "~/go/bin" "
export PATH=$PATH:/usr/local/go/bin:~/go/bin"

# create go directory
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/go"

# create directory for testing and keeping scripts
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/_testing"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/_scripts"

# clone dynamixel tools into _testing
if [ ! -d "${ROOTFS_DIR}/home/pi/_testing/dxl-cli" ]; then
    on_chroot << EOF
    git clone https://github.com/aimlabmu/dxl-cli.git /home/pi/_testing/dxl-cli
EOF
fi

# change ownership of _testing
chown -R 1000:1000 "${ROOTFS_DIR}/home/pi/_testing"

# add dependencieds installation script to _script
cp files/installRequirements.sh "${ROOTFS_DIR}/home/pi/_scripts/installRequirements.sh"

# change ownership of _testing
chown 1000:1000 "${ROOTFS_DIR}/home/pi/_scripts/installRequirements.sh"

# run installation script
on_chroot << EOF
    ./home/pi/_scripts/installRequirements.sh
EOF

# change permission of _installations
chown -R 1000:1000 "${ROOTFS_DIR}/home/pi/_installations"

