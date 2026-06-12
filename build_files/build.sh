#!/bin/bash

set -ouex pipefail

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

## Install cosmic
bash /ctx/cosmic.sh

### Install packages
bash /ctx/chrome.sh


dnf -y install papirus-icon-theme bibata-cursor-theme
dnf -y install distrobox tmux

## Fish installation and configuration
dnf -y install fish
sed -i 's|^SHELL=/bin/bash|SHELL=/usr/bin/fish|' /etc/default/useradd
mkdir -p /etc/skel/.config/
cp -r /ctx/dotfiles/fish /etc/skel/.config/

## Change logo
cp /ctx/res/logo/logo.png /usr/share/plymouth/themes/spinner/watermark.png
cp /ctx/res/logo/logo.png /usr/share/plymouth/themes/spinner/bgrt-fallback.png

cp /ctx/res/logo/logo.png /usr/share/pixmaps/system-logo-white.png

## Setup Podman
dnf -y install docker-compose podman-docker
echo 'L+ /var/run/docker.sock - - - - /run/podman/podman.sock' > /usr/lib/tmpfiles.d/podman-docker-socket.conf

systemctl enable podman.socket

dnf5 -y clean all
rm -rf /run/dnf /run/selinux-policy
rm -rf /var/lib/dnf
