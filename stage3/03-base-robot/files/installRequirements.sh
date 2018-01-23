#!/bin/bash -e

## clone ffmpeg
if [ ! -d /home/pi/_installations/FFmpeg ]; then
    echo "FFmpeg is not in _installations, cloning..."
    git clone --depth=1 https://github.com/FFmpeg/FFmpeg.git /home/pi/_installations/FFmpeg
fi

## configure and make ffmpeg
if [ ! -d /usr/local/ffmpeg ]; then
    echo "FFmpeg is already in _installations, configuring and making..."
    cd /home/pi/_installations/FFmpeg
    ./configure --prefix=/usr/local/ffmpeg --enable-shared
    make -j4
    make install
fi

## install mqttBackend
# dependencies for raylib, mqtt, and node-ghk
apt-get install -y libopenal-dev libgl1-mesa-dev libxi-dev libxinerama-dev libxcursor-dev libxxf86vm-dev libxrandr-dev
apt-get install -y cmake libx11-dev libxtst-dev libxt-dev libx11-xcb-dev libxkbcommon-dev libxkbcommon-x11-dev libtool autoconf libxinerama-dev libxkbfile-dev

## install python dependencies
pip3 install paho-mqtt
pip3 install rx

## install zeromq
apt-get install -y libtool pkg-config build-essential autoconf automake

if [ ! -e /home/pi/_installations/libsodium-1.0.3.tar.gz ]; then
    echo "libsodium is not installed, downloading.."
    cd /home/pi/_installations/
    wget https://github.com/jedisct1/libsodium/releases/download/1.0.3/libsodium-1.0.3.tar.gz
    tar -zxvf libsodium-1.0.3.tar.gz
    cd libsodium-1.0.3/
    ./configure
    make
    sudo make install
fi

export http_proxy="http://<x>:<y>@proxy-sa.mahidol:8080"
echo "Proxy exported succesfully."

if [ ! -e /home/pi/_installations/zeromq-4.1.3.tar.gz ]; then
    echo "zeromq is not installed, downloading.."
    cd /home/pi/_installations/
    wget http://download.zeromq.org/zeromq-4.1.3.tar.gz
    tar -zxvf zeromq-4.1.3.tar.gz
    cd zeromq-4.1.3/
    ./configure
    make
    sudo make install
    sudo ldconfig
fi