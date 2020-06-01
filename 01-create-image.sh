#!/bin/sh

set -e

sudo ROOTFS_DIR=$(pwd)/rootfs-dirty Linux_for_Tegra/tools/jetson-disk-image-creator.sh -o sd-blob.img -b jetson-nano -r 200
