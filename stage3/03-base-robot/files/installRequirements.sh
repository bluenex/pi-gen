#!/bin/bash -e

####
# it's easier to define path without $PREFIX (${ROOTFS_DIR})
# so we move building step into this installRequirements.sh
####

## clone ffmpeg
if [ ! -d /home/pi/_installations/FFmpeg ]; then
    echo "FFmpeg is not in _installations, cloning..."
    git clone --depth=1 https://github.com/FFmpeg/FFmpeg.git /home/pi/_installations/FFmpeg
fi

## configure, make, and install ffmpeg
if [ ! -d /usr/local/ffmpeg ]; then
    echo "FFmpeg is already in _installations, configuring and making..."
    cd /home/pi/_installations/FFmpeg
    ./configure --prefix=/usr/local/ffmpeg --enable-shared
    make -j4
    make install
fi

## configure, make, and install libsodium to help install zeromq
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

## zeromq downloading requires proxy, so export it
export http_proxy="http://<x>:<y>@proxy-sa.mahidol:8080"
echo "Proxy exported succesfully."

## configure, make, and install zeromq lib
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