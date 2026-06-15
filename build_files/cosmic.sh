#!/usr/bin/bash

set -eoux pipefail


# Source helper functions
# shellcheck source=/dev/null
source /ctx/copr-helpers.sh


echo "::group:: Install COSMIC Desktop"

# Install COSMIC desktop from System76's COPR
# Using isolated pattern to prevent COPR from persisting
copr_install_isolated "ryanabx/cosmic-epoch" \
    cosmic-session \
    cosmic-greeter \
    cosmic-comp \
    cosmic-panel \
    cosmic-launcher \
    cosmic-applets \
    cosmic-settings \
    cosmic-files \
    cosmic-edit \
    cosmic-term \
    cosmic-workspaces

echo "COSMIC desktop installed successfully"
echo "::endgroup::"

echo "::group:: Configure Display Manager"

# Enable cosmic-greeter (COSMIC's display manager)
systemctl enable -f cosmic-greeter.service
systemctl set-default graphical.target

# Set COSMIC as default session
mkdir -p /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/cosmic.desktop << 'COSMICDESKTOP'
[Desktop Entry]
Name=COSMIC
Comment=COSMIC Desktop Environment
Exec=cosmic-session
Type=Application
DesktopNames=COSMIC
COSMICDESKTOP

echo "Display manager configured"
echo "::endgroup::"

echo "::group:: Install Additional Utilities"

# Install additional utilities and essential desktop components
dnf -y install \
    kitty \
    flatpak \
    xdg-desktop-portal-cosmic \
    pipewire wireplumber pipewire-pulseaudio pipewire-alsa \
    NetworkManager-wifi bluez bluez-obexd \
    upower power-profiles-daemon \
    xdg-user-dirs wl-clipboard \
    google-noto-color-emoji-fonts google-noto-sans-fonts

# Enable necessary services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable power-profiles-daemon
echo "Additional utilities installed"
echo "::endgroup::"

echo "COSMIC desktop installation complete!"
echo "After booting, select 'COSMIC' session at the login screen"
