#!/bin/sh

set -e

pushd Linux_for_Tegra >> /dev/null
sudo ./flash.sh -k APP -R ../rootfs-dirty jetson-nano-qspi-sd mmcblk0p1
popd >> /dev/null
