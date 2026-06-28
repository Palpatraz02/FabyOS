#!/usr/bin/env bash

set -oue pipefail

## Install Proton Pass CLI
export PROTON_PASS_CLI_INSTALL_DIR=/usr/bin
mkdir -p "$PROTON_PASS_CLI_INSTALL_DIR"
if [ -d /etc/sudoers.d ]; then
    chmod 0755 /etc/sudoers.d
fi
curl -fsSL https://proton.me/download/pass-cli/install.sh | bash

## Install proton pass
curl -L -o /tmp/ProtonPass.rpm https://proton.me/download/PassDesktop/linux/x64/ProtonPass.rpm
dnf -y install /tmp/ProtonPass.rpm
rm /tmp/ProtonPass.rpm
