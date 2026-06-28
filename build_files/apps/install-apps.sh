#!/usr/bin/bash

set -eoux pipefail

## Install cosmic
bash /ctx/apps/cosmic.sh

## Install chrome
# bash /ctx/apps/chrome.sh

## Install brave
bash /ctx/apps/brave.sh

## INstall proton
curl -L -o /tmp/ProtonPass.rpm https://proton.me/download/PassDesktop/linux/x64/ProtonPass.rpm
dnf -y install /tmp/ProtonPass.rpm
rm /tmp/ProtonPass.rpm

dnf -y install papirus-icon-theme bibata-cursor-theme
dnf -y install $(grep -vE '^\s*(#|$)' /ctx/apps/pkgs.txt)

## Install Proton Pass CLI
export PROTON_PASS_CLI_INSTALL_DIR=/usr/local/bin
curl -fsSL https://proton.me/download/pass-cli/install.sh | bash
