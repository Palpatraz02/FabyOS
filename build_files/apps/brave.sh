#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

### Install Brave from Official Repository
echo "Installing Brave..."

# Add Brave RPM repository
curl -fsSLo /etc/yum.repos.d/brave-browser.repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

# Install Brave
dnf -y install brave-browser

# Clean up repo file (required - repos don't work at runtime in bootc images)
rm -f /etc/yum.repos.d/brave-browser.repo

echo "Brave installed successfully"
