#!/bin/bash

set -ouex pipefail

source /ctx/dnf.sh

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

dnf -y install dnf5-plugins
dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

bash /ctx/apps/cosmic.sh
bash /ctx/apps/install-apps.sh
bash /ctx/nvidia.sh

## Theme defaults
mkdir -p /usr/share/icons/default
cat > /usr/share/icons/default/index.theme << 'THEMEDEFAULTS'
[Icon Theme]
Inherits=Bibata-Modern-Classic
THEMEDEFAULTS

mkdir -p /etc/skel/.config/gtk-3.0 /etc/skel/.config/gtk-4.0
cat > /etc/skel/.config/gtk-3.0/settings.ini << 'GTKSETTINGS'
[Settings]
gtk-icon-theme-name=Papirus
gtk-cursor-theme-name=Bibata-Modern-Classic
GTKSETTINGS
cp /etc/skel/.config/gtk-3.0/settings.ini /etc/skel/.config/gtk-4.0/settings.ini



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


## Rebuild initramfs to apply the new boot logo
KVER=$(cd /usr/lib/modules && echo *)
dracut -vf --no-hostonly --add ostree /usr/lib/modules/$KVER/initramfs.img "$KVER"

## Setup Podman
dnf -y install docker-compose podman-docker
echo 'L+ /var/run/docker.sock - - - - /run/podman/podman.sock' > /usr/lib/tmpfiles.d/podman-docker-socket.conf

systemctl enable podman.socket

rm -f /etc/yum.repos.d/terra*.repo

# Temporary fix for repo.rakuos.org 403 Forbidden error during ISO build
# sed -i 's|^gpgkey=https://repo.rakuos.org/pubkey.gpg|#gpgkey=|g' /etc/yum.repos.d/*.repo || true
# sed -i 's|^gpgcheck=1|gpgcheck=0|g' /etc/yum.repos.d/rakuos*.repo || true

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
chmod +x /usr/libexec/users-setup/faby02/configure_brave.sh

# 2. Install the user service
mkdir -p /usr/lib/systemd/user/
cp /ctx/users-setup/first-login.service /usr/lib/systemd/user/

# 3. Enable the service globally for all users
systemctl --global enable first-login.service

bash /ctx/cleanup.sh
