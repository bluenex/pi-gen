#!/bin/bash -e

if [ ! -d ${ROOTFS_DIR} ]; then
	copy_previous
fi

# if we are gonna use the same stage0-2 as base 
# we need to update && upgrade system first
on_chroot << EOF
apt-get update
apt-get -y upgrade
EOF
