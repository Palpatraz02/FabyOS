#!/bin/bash
set -e

# Ensure Flathub is added system-wide
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Bitwarden Desktop system-wide
# flatpak install --system -y flathub com.bitwarden.desktop
