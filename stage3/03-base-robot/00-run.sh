#!/bin/bash -e

source ../commands

#Alacarte fixes
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share/applications"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/.local/share/desktop-directories"

###########################################################################################

#Network config
if_no_text_then_add "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf" "$wifiUsr" "
ap_scan=1

network={
    ssid=\"$wifiUsr\"
    psk=\"$wifiPw\"
}"

on_chroot << EOF
    systemctl enable wpa_supplicant.service
EOF

###########################################################################################

#Screen rotation (comment these lines if dont wanna rotate screen)
if_no_text_then_add "${ROOTFS_DIR}/boot/config.txt" "display_rotate=2" "
### Custom Settings
# display
hdmi_group=2
hdmi_mode=87
hdmi_cvt 800 480 60 6 0 0 0
display_rotate=2"

###########################################################################################

#Proxy (comment these lines if dont want proxy settings)
# if_no_text_then_add "${ROOTFS_DIR}/etc/apt/apt.conf.d/10proxy" "Acquire::http::proxy" "
# Acquire::http::proxy \"http://$proxyUsr:$proxyPw@proxy-sa.mahidol:8080/\";"

###########################################################################################

##i2c
# sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/g" "${ROOTFS_DIR}/boot/config.txt"
replace_this_with_that "${ROOTFS_DIR}/boot/config.txt" "#dtparam=i2c_arm=on" "dtparam=i2c_arm=on" 

if_no_text_then_add "${ROOTFS_DIR}/etc/modules" "snd-bcm2835" "
i2c-dev
snd-bcm2835"

# i2c-tools and python3-smbus are installed in 00-packages of stage3

###########################################################################################

# add uart config
if_no_text_then_add "${ROOTFS_DIR}/boot/config.txt" "#core_freq=250" '
# Set uart clock
enable_uart=1
#init_uart_clock=16000000
#sudo stty -F /dev/ttyAMA0 1000000

# Workaround for uart on RPi3
#core_freq=250'

###########################################################################################

##Nodejs
if [ ! -e "${ROOTFS_DIR}/usr/bin/node" ]; then
    on_chroot << EOF
    curl -sL https://deb.nodesource.com/setup_8.x | bash -
    apt-get install -y nodejs
EOF
fi

###########################################################################################

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

###########################################################################################

# create directory for testing and keeping scripts
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/_testing"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/_scripts"
# install _ directories (moved from 04-elderly-robot)
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/_log"
install -v -o 1000 -g 1000 -d "${ROOTFS_DIR}/home/pi/_projects"

###########################################################################################

# clone dynamixel tools into _testing
if [ ! -d "${ROOTFS_DIR}/home/pi/_testing/dxl-cli" ]; then
    on_chroot << EOF
    git clone https://github.com/aimlabmu/dxl-cli.git /home/pi/_testing/dxl-cli
EOF
fi

# change ownership of _testing
chown -R 1000:1000 "${ROOTFS_DIR}/home/pi/_testing"

###########################################################################################

# install dependencies for raylib, mqtt, and node-ghk
# install zeromq
# install python dependencies for mqttBackend
on_chroot << EOF
    apt-get install -y libopenal-dev libgl1-mesa-dev libxi-dev libxinerama-dev libxcursor-dev libxxf86vm-dev libxrandr-dev
    apt-get install -y cmake libx11-dev libxtst-dev libxt-dev libx11-xcb-dev libxkbcommon-dev libxkbcommon-x11-dev libtool autoconf libxinerama-dev libxkbfile-dev
    apt-get install -y libtool pkg-config build-essential autoconf automake
    pip3 install paho-mqtt rx
EOF

###########################################################################################

## copy build script to image
# replace proxy user and pw before copying
sed -i "s/<x>/$proxyUsr/g" files/installRequirements.sh
sed -i "s/<y>/$proxyPw/g" files/installRequirements.sh

echo "Replace some texts before copying."
cat files/installRequirements.sh | grep 'export http_proxy'

# copy building script to _script
cp files/installRequirements.sh "${ROOTFS_DIR}/home/pi/_scripts/installRequirements.sh"

# replace proxy user and pw back to dummies
sed -i "s/$proxyUsr/<x>/g" files/installRequirements.sh
sed -i "s/$proxyPw/<y>/g" files/installRequirements.sh

echo "Replace some texts back to original."
cat files/installRequirements.sh | grep 'export http_proxy'

# change ownership of _testing
chown 1000:1000 "${ROOTFS_DIR}/home/pi/_scripts/installRequirements.sh"

# run installation script
on_chroot << EOF
    ./home/pi/_scripts/installRequirements.sh
EOF

# change permission of _installations
chown -R 1000:1000 "${ROOTFS_DIR}/home/pi/_installations"

###########################################################################################

# clone first-boot-scripts into _scripts if no repo yet
# pull if there is already a repo
scriptPath="${ROOTFS_DIR}/home/pi/_scripts/first-boot-scripts"
if [ ! -d $scriptPath ]; then
    on_chroot << EOF
    git clone https://github.com/aimlabmu/first-boot-scripts /home/pi/_scripts/first-boot-scripts
EOF
else
    on_chroot << EOF
    git --work-tree=/home/pi/_scripts/first-boot-scripts --git-dir=/home/pi/_scripts/first-boot-scripts/.git pull origin master
EOF
fi

# change ownership of _scripts
chown -R 1000:1000 "${ROOTFS_DIR}/home/pi/_scripts"

###########################################################################################

# # add script to clone project to ~/_projects (this need to be run manually after boot)
# cp files/clone-elderly-robot-repo.sh "${ROOTFS_DIR}/home/pi/_scripts/clone-elderly-robot-repo.sh"

# # change ownership of the copied scripts
# chown 1000:1000 "${ROOTFS_DIR}/home/pi/_scripts/clone-elderly-robot-repo.sh"

# add ffmpeg path
if_no_text_then_add "${ROOTFS_DIR}/home/pi/.bashrc" '# ffmpeg path' '
# ffmpeg path
export PATH=$PATH:/usr/local/ffmpeg/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/ffmpeg/lib
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/ffmpeg/lib/pkgconfig/'