#!/bin/sh

set -e

msg() {
    echo -e "\033[0;32m$@\033[0m" >&2
}

msg "Disabling the ondemand service..."
for file in /etc/rc[0-9].d/; do
	if [ -f "${file}"/S*ondemand ]; then
		mv "${file}"/S*ondemand "${file}/K01ondemand"
	fi
done
if [ -h "/etc/systemd/system/multi-user.target.wants/ondemand.service" ]; then
	rm -f "/etc/systemd/system/multi-user.target.wants/ondemand.service"
fi

msg "Temporarily disabling a platform-dependent repository..."
sed -i '/<SOC>/ s/^/# /' /etc/apt/sources.list.d/nvidia-l4t-apt-source.list

msg "Installing additional CUDA packages..."
apt-get update
apt-get install --no-install-recommends -y nvidia-docker2

msg "Enabling the platform-dependent repository back..."
sed -i '/<SOC>/ s/^# //' /etc/apt/sources.list.d/nvidia-l4t-apt-source.list

msg "Patching oem-config..."
ln -sf /bin/true /usr/bin/grub-editenv
rm -f /usr/share/ubiquity/zsys-setup

msg "Patching default user groups..."
sed -i "/#EXTRA_GROUPS=/ s/^.*/EXTRA_GROUPS=\"gpio sudo docker\"/" /etc/adduser.conf
sed -i "/#ADD_EXTRA_GROUPS=/ s/^.*/ADD_EXTRA_GROUPS=1/" /etc/adduser.conf
