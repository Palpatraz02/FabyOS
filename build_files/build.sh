#!/bin/bash

set -ouex pipefail

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

##! Temp fix of terra
curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo -o /etc/yum.repos.d/terra.repo
dnf -y install terra-release

## Install cosmic
bash /ctx/cosmic.sh

### Install chrome
bash /ctx/chrome.sh


dnf -y install papirus-icon-theme bibata-cursor-theme
dnf -y install $(grep -v '^#' /ctx/pkgs.txt)

## Install bitwarden cli
curl -L -o /tmp/bw.zip "https://vault.bitwarden.com/download/?app=cli&platform=linux"
unzip /tmp/bw.zip -d /usr/bin/
chmod +x /usr/bin/bw
rm /tmp/bw.zip

## Fish installation and configuration
dnf -y install fish
sed -i 's|^SHELL=/bin/bash|SHELL=/usr/bin/fish|' /etc/default/useradd
mkdir -p /usr/share/fish/
mkdir -p /etc/skel/.config/
cp -r /ctx/default/fish/ /usr/share/
cp -r /ctx/dotfiles/fish/ /etc/skel/.config


## Change logo
cp /ctx/res/logo/logo.png /usr/share/plymouth/themes/spinner/watermark.png
cp /ctx/res/logo/logo.png /usr/share/plymouth/themes/spinner/bgrt-fallback.png

cp /ctx/res/logo/logo.png /usr/share/pixmaps/system-logo-white.png

## Rebuild initramfs to apply the new boot logo
KVER=$(cd /usr/lib/modules && echo *)
dracut -vf /usr/lib/modules/$KVER/initramfs.img "$KVER"

## Setup Podman
dnf -y install docker-compose podman-docker
echo 'L+ /var/run/docker.sock - - - - /run/podman/podman.sock' > /usr/lib/tmpfiles.d/podman-docker-socket.conf

systemctl enable podman.socket

rm -f /etc/yum.repos.d/terra*.repo

# Temporary fix for repo.rakuos.org 403 Forbidden error during ISO build
sed -i 's|^gpgkey=https://repo.rakuos.org/pubkey.gpg|#gpgkey=|g' /etc/yum.repos.d/*.repo || true
sed -i 's|^gpgcheck=1|gpgcheck=0|g' /etc/yum.repos.d/rakuos*.repo || true

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
