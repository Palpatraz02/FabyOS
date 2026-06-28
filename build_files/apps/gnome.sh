#!/usr/bin/bash

set -eoux pipefail

echo "::group:: Install GNOME Desktop"

# Install GNOME desktop components from Fedora repositories.
dnf -y install \
    gdm \
    gnome-shell \
    gnome-session-wayland-session \
    gnome-control-center \
    gnome-settings-daemon \
    gnome-keyring \
    nautilus \
    gnome-terminal \
    gnome-text-editor \
    gnome-system-monitor \
    gnome-disk-utility \
    gnome-tweaks \
    xdg-desktop-portal-gnome

echo "GNOME desktop installed successfully"
echo "::endgroup::"

echo "::group:: Configure Display Manager"

# Enable GDM as the display manager.
systemctl enable -f gdm.service
systemctl set-default graphical.target

# Ensure the GNOME Wayland session entry exists.
mkdir -p /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/gnome.desktop << 'GNOMEDESKTOP'
[Desktop Entry]
Name=GNOME
Comment=GNOME Desktop Environment
Exec=gnome-session
Type=Application
DesktopNames=GNOME
GNOMEDESKTOP

echo "Display manager configured"
echo "::endgroup::"

echo "::group:: Install Additional Utilities"

# Install additional utilities and essential desktop components.
dnf -y install \
    kitty \
    flatpak \
    pipewire wireplumber pipewire-pulseaudio pipewire-alsa \
    NetworkManager-wifi bluez bluez-obexd \
    upower \
    xdg-user-dirs wl-clipboard \
    google-noto-color-emoji-fonts google-noto-sans-fonts \
    coreutils

# Enable necessary services.
systemctl enable NetworkManager
systemctl enable bluetooth

echo "Additional utilities installed"
echo "::endgroup::"

echo "GNOME desktop installation complete!"
echo "After booting, select 'GNOME' session at the login screen"
