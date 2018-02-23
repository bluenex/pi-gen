#!/bin/bash -e

source ../commands

#### these are moved to 03-base-robot/00-run.sh
# # clone first-boot-scripts into _scripts if no repo yet
# # pull if there is already a repo
# scriptPath="${ROOTFS_DIR}/home/pi/_scripts/first-boot-scripts"
# if [ ! -d $scriptPath ]; then
#     on_chroot << EOF
#     git clone https://github.com/aimlabmu/first-boot-scripts /home/pi/_scripts/first-boot-scripts
# EOF
# else
#     on_chroot << EOF
#     git --work-tree=/home/pi/_scripts/first-boot-scripts --git-dir=/home/pi/_scripts/first-boot-scripts/.git pull origin master
# EOF
# fi

# # change ownership of _scripts
# chown -R 1000:1000 "${ROOTFS_DIR}/home/pi/_scripts"

# # # add script to clone project to ~/_projects (this need to be run manually after boot)
# # cp files/clone-elderly-robot-repo.sh "${ROOTFS_DIR}/home/pi/_scripts/clone-elderly-robot-repo.sh"

# # # change ownership of the copied scripts
# # chown 1000:1000 "${ROOTFS_DIR}/home/pi/_scripts/clone-elderly-robot-repo.sh"

# # add ffmpeg path
# if_no_text_then_add "${ROOTFS_DIR}/home/pi/.bashrc" '# ffmpeg path' '
# # ffmpeg path
# export PATH=$PATH:/usr/local/ffmpeg/bin
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/ffmpeg/lib
# export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/ffmpeg/lib/pkgconfig/'