#!/usr/bin/bash

set -eoux pipefail

## Install cosmic
bash /ctx/apps/cosmic.sh

### Install chrome
bash /ctx/apps/chrome.sh


dnf -y install papirus-icon-theme bibata-cursor-theme
dnf -y install $(grep -vE '^\s*(#|$)' /ctx/apps/pkgs.txt)

## Install bitwarden cli
curl -L -o /tmp/bw.zip "https://vault.bitwarden.com/download/?app=cli&platform=linux"
unzip /tmp/bw.zip -d /usr/bin/
chmod +x /usr/bin/bw
rm /tmp/bw.zip
