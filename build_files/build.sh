#!/bin/bash

set -ouex pipefail

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

## Install cosmic

#bash /ctx/cosmic.sh

### Install packages

#bash /ctx/chrome.sh


dnf -y install papirus-icon-theme bibata-cursor-theme
dnf -y install distrobox tmux

systemctl enable podman.socket

dnf5 -y clean all
rm -rf /run/dnf /run/selinux-policy
rm -rf /var/lib/dnf
