#!/usr/bin/bash

set -eoux pipefail


# Source helper functions
# shellcheck source=/dev/null
source /ctx/apps/copr-helpers.sh


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
    cosmic-workspaces \
    cosmic-monitor

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
    xdg-desktop-portal xdg-desktop-portal-gtk \
    xdg-desktop-portal-cosmic \
    xorg-x11-server-Xwayland \
    polkit accountsservice \
    gvfs gvfs-mtp gvfs-gphoto2 gvfs-smb udisks2 \
    rtkit \
    xdg-utils shared-mime-info desktop-file-utils \
    alsa-utils pavucontrol \
    brightnessctl playerctl \
    fprintd switcheroo-control \
    firewalld firewall-config \
    pipewire wireplumber pipewire-pulseaudio pipewire-alsa \
    NetworkManager-wifi bluez bluez-obexd \
    NetworkManager-tui \
    cups cups-pk-helper system-config-printer \
    iio-sensor-proxy geoclue2 bolt \
    upower \
    xdg-user-dirs wl-clipboard \
    google-noto-color-emoji-fonts google-noto-sans-fonts \
    google-noto-serif-fonts google-noto-sans-mono-fonts \
    liberation-fonts dejavu-sans-fonts \
    coreutils

# Enable necessary services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups
systemctl enable switcheroo-control
systemctl enable firewalld
echo "Additional utilities installed"
echo "::endgroup::"

echo "COSMIC desktop installation complete!"
echo "After booting, select 'COSMIC' session at the login screen"
