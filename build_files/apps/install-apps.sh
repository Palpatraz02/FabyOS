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

## Install JetBrainsMono Nerd Font
tmpdir="$(mktemp -d)"
curl -fsSL \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
    -o "${tmpdir}/JetBrainsMono.zip"
mkdir -p /usr/local/share/fonts/JetBrainsMonoNerdFont
unzip -q "${tmpdir}/JetBrainsMono.zip" \
    -d /usr/local/share/fonts/JetBrainsMonoNerdFont
find /usr/local/share/fonts/JetBrainsMonoNerdFont -type f ! -name '*.ttf' ! -name '*.otf' -delete
find /usr/local/share/fonts/JetBrainsMonoNerdFont -type d -exec chmod 0755 {} \;
find /usr/local/share/fonts/JetBrainsMonoNerdFont -type f -exec chmod 0644 {} \;
fc-cache -f
rm -rf "${tmpdir}"
