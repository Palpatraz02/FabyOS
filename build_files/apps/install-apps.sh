#!/usr/bin/bash

set -eoux pipefail

## Install cosmic
bash /ctx/apps/cosmic.sh

## Install chrome
# bash /ctx/apps/chrome.sh

## Install brave
bash /ctx/apps/brave.sh

bash /ctx/apps/proton.sh



dnf -y install papirus-icon-theme bibata-cursor-theme
dnf -y install $(grep -vE '^\s*(#|$)' /ctx/apps/pkgs.txt)
