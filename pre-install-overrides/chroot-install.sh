#!/bin/sh

set -e

msg() {
    echo "\033[0;32m$@\033[0m" >&2
}

/debootstrap/debootstrap --second-stage
echo "root:root" | chpasswd

msg "Installing required packages..."
apt-get install --no-install-recommends -y sudo device-tree-compiler whiptail kmod net-tools bridge-utils \
    debconf-utils wpasupplicant network-manager linux-firmware isc-dhcp-client initramfs-tools ucf pciutils \
    usbutils apt-utils openssh-server wireless-tools curl gnupg ca-certificates parted gdisk

msg "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-get update
apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io

msg "Installing oem-config..."
apt-get install --no-install-recommends -y ubiquity-frontend-debconf oem-config-debconf
apt-mark auto ubiquity-frontend-debconf oem-config-debconf

msg "Installing a dummy package for L4T dependencies..."
dpkg -i /var/jetson-dummy-package/dummy-l4t-packages_1.0_all.deb
rm -rf /var/jetson-dummy-package
