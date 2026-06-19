#!/bin/bash

set -ouex pipefail

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

##! Temp fix of terra
curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo -o /etc/yum.repos.d/terra.repo
dnf -y install terra-release

bash /ctx/apps/install-apps.sh
dnf -y swap uutils-coreutils coreutils

## Fish installation and configuration
dnf -y install fish
sed -i 's|^SHELL=/bin/bash|SHELL=/usr/bin/fish|' /etc/default/useradd
mkdir -p /usr/share/fish/
mkdir -p /etc/skel/.config/
cp -r /ctx/defaults/fish/ /usr/share/
cp -r /ctx/dotfiles/fish/ /etc/skel/.config


## Change logo
cp /ctx/res/logo/logo.png /usr/share/plymouth/themes/spinner/watermark.png
cp /ctx/res/logo/logo.png /usr/share/plymouth/themes/spinner/bgrt-fallback.png

cp /ctx/res/logo/logo.png /usr/share/pixmaps/system-logo-white.png

## Change GRUB option name
if [ -f /etc/default/grub ]; then
    sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="FabyOS"/' /etc/default/grub

    if grep -q "^GRUB_TIMEOUT=" /etc/default/grub; then
        sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
    else
        echo 'GRUB_TIMEOUT=1' >> /etc/default/grub
    fi

    if grep -q "^GRUB_TIMEOUT_STYLE=" /etc/default/grub; then
        sed -i 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub
    else
        echo 'GRUB_TIMEOUT_STYLE=hidden' >> /etc/default/grub
    fi
fi

## Rebuild initramfs to apply the new boot logo
KVER=$(cd /usr/lib/modules && echo *)
dracut -vf --no-hostonly --add ostree /usr/lib/modules/$KVER/initramfs.img "$KVER"

## Setup Podman
dnf -y install docker-compose podman-docker
echo 'L+ /var/run/docker.sock - - - - /run/podman/podman.sock' > /usr/lib/tmpfiles.d/podman-docker-socket.conf

systemctl enable podman.socket

rm -f /etc/yum.repos.d/terra*.repo

# Temporary fix for repo.rakuos.org 403 Forbidden error during ISO build
sed -i 's|^gpgkey=https://repo.rakuos.org/pubkey.gpg|#gpgkey=|g' /etc/yum.repos.d/*.repo || true
sed -i 's|^gpgcheck=1|gpgcheck=0|g' /etc/yum.repos.d/rakuos*.repo || true

## System setup
cp -r /ctx/system-setup /usr/libexec/
chmod +x /usr/libexec/system-setup/first-boot.sh

cp /ctx/system-setup/first-boot.service /usr/lib/systemd/system/
systemctl enable first-boot.service

# 1. Install the setup script
cp -r /ctx/users-setup /usr/libexec/
chmod +x /usr/libexec/users-setup/first-login.sh

chmod +x /usr/libexec/users-setup/faby02/setup.sh
chmod +x /usr/libexec/users-setup/faby02/restore.sh

# 2. Install the user service
mkdir -p /usr/lib/systemd/user/
cp /ctx/users-setup/first-login.service /usr/lib/systemd/user/

# 3. Enable the service globally for all users
systemctl --global enable first-login.service

dnf5 -y clean all
rm -rf /run/dnf /run/selinux-policy
rm -rf /var/lib/dnf
