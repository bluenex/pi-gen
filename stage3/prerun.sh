#!/bin/bash -e

if [ ! -d ${ROOTFS_DIR} ]; then
	copy_previous
fi

# for internet which has no proxy, removing proxy settings file from old rootfs is needed
if [ -e "${ROOTFS_DIR}/etc/apt/apt.conf.d/10proxy" ]; then
	echo "10proxy is detected!"

    on_chroot << EOF
    rm "/etc/apt/apt.conf.d/10proxy"
EOF

	echo "10proxy is DELETED!"
fi

# if we are gonna use the same stage0-2 as base 
# we need to update && upgrade system first
on_chroot << EOF
apt-get update
apt-get -y upgrade
EOF
