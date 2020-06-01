#!/bin/sh

set -e

msg() {
    echo -e "\033[0;32m$@\033[0m" >&2
}
msg_warn() {
    echo -e "\033[0;33m$@\033[0m" >&2
}

export PATH="/sbin:/usr/sbin:$PATH"
export LC_ALL="C"
export DEBIAN_FRONTEND="noninteractive"

if [ ! -d "Linux_for_Tegra" ]; then
    msg "Downloading drivers BSP for Jetson Nano..."
    curl -L https://developer.nvidia.com/embedded/L4T/r32_Release_v4.2/t210ref_release_aarch64/Tegra210_Linux_R32.4.2_aarch64.tbz2 | tar -xj

    msg "Patching 'nv_tegra/nv-apply-debs.sh'..."
    sed -i 's/dpkg -i/dpkg --force-overwrite -i/g' Linux_for_Tegra/nv_tegra/nv-apply-debs.sh
else
    msg_warn "Skipping a drivers BSP downloading - directory already exists..."
fi

if [ ! -d "rootfs-clean" ]; then
    mkdir rootfs-clean

    msg "Bootstraping Ubuntu Focal..."
    sudo debootstrap --variant=minbase --arch=arm64 --components=main,universe --foreign focal rootfs-clean http://ports.ubuntu.com/ubuntu-ports

    msg "Copying pre-install overrides to the rootfs..."
    sudo cp -rv pre-install-overrides/* rootfs-clean

    msg "Running installation script in the chroot"
    sudo cp -av /usr/bin/qemu-aarch64-static rootfs-clean/usr/bin
    sudo chroot rootfs-clean /chroot-install.sh
    sudo rm rootfs-clean/usr/bin/qemu-aarch64-static
    sudo rm rootfs-clean/chroot-install.sh
else
    msg_warn "Skipping a clean RootFS bootstraping - directory already exists..."
fi

sudo rm -rf rootfs-dirty
sudo cp -ar rootfs-clean rootfs-dirty

msg "Removing extra packages..."
rm -f Linux_for_Tegra/nv_tegra/l4t_deb_packages/nvidia-l4t-camera*
rm -f Linux_for_Tegra/nv_tegra/l4t_deb_packages/nvidia-l4t-graphics-demos*
rm -f Linux_for_Tegra/nv_tegra/l4t_deb_packages/nvidia-l4t-gstreamer*
rm -f Linux_for_Tegra/nv_tegra/l4t_deb_packages/nvidia-l4t-multimedia*
rm -f Linux_for_Tegra/nv_tegra/l4t_deb_packages/nvidia-l4t-wayland*
rm -f Linux_for_Tegra/nv_tegra/l4t_deb_packages/nvidia-l4t-weston*
rm -f Linux_for_Tegra/nv_tegra/l4t_deb_packages/nvidia-l4t-x11*
rm -f Linux_for_Tegra/tools/python-jetson*

msg "Installing essential NVIDIA packages..."
sudo L4T_ROOTFS_DIR="$(pwd)/rootfs-dirty" Linux_for_Tegra/nv_tegra/nv-apply-debs.sh

msg "Copying USB device mode filesystem image..."
sudo cp -ar Linux_for_Tegra/nv_tegra/l4t-usb-device-mode-filesystem.img rootfs-dirty/opt/nvidia/l4t-usb-device-mode/filesystem.img

msg "Installing extlinux.conf into /boot/extlinux in target rootfs..."
sudo mkdir -p rootfs-dirty/boot/extlinux/
sudo cp -ar Linux_for_Tegra/bootloader/extlinux.conf rootfs-dirty/boot/extlinux/extlinux.conf

msg "Copying post-install overrides to the rootfs..."
sudo cp -rv post-install-overrides/* rootfs-dirty

msg "Running installation script in the chroot"
sudo cp -av /usr/bin/qemu-aarch64-static rootfs-dirty/usr/bin
sudo chroot rootfs-dirty /chroot-install.sh
sudo rm rootfs-dirty/usr/bin/qemu-aarch64-static
sudo rm rootfs-dirty/chroot-install.sh
