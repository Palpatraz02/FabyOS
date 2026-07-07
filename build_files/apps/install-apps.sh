#!/usr/bin/bash

set -eoux pipefail

## Install cosmic
bash /ctx/apps/cosmic.sh

## Install chrome
# bash /ctx/apps/chrome.sh

## Install brave
bash /ctx/apps/brave.sh

bash /ctx/apps/proton.sh

## Install Zed
bash /ctx/apps/zed.sh

## Install Codex CLI
bash /ctx/apps/codex.sh

dnf -y install papirus-icon-theme bibata-cursor-theme
dnf -y install $(grep -vE '^\s*(#|$)' /ctx/apps/pkgs.txt)

## Install JetBrainsMono Nerd Font
tmpdir="$(mktemp -d)"
fontdir="/usr/share/fonts/JetBrainsMonoNerdFont"
curl -fsSL \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
    -o "${tmpdir}/JetBrainsMono.zip"
mkdir -p "${fontdir}"
unzip -q "${tmpdir}/JetBrainsMono.zip" \
    -d "${fontdir}"
find "${fontdir}" -type f ! -name '*.ttf' ! -name '*.otf' -delete
find "${fontdir}" -type d -exec chmod 0755 {} \;
find "${fontdir}" -type f -exec chmod 0644 {} \;
fc-cache -f
rm -rf "${tmpdir}"
