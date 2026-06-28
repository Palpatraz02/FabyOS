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
    file-roller\
    loupe \
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
    xdg-desktop-portal xdg-desktop-portal-gtk \
    xorg-x11-server-Xwayland \
    polkit accountsservice \
    gvfs gvfs-mtp gvfs-gphoto2 gvfs-smb udisks2 \
    power-profiles-daemon rtkit \
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

# Enable necessary services.
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups
systemctl enable power-profiles-daemon
systemctl enable switcheroo-control
systemctl enable firewalld

echo "Additional utilities installed"
echo "::endgroup::"

echo "GNOME desktop installation complete!"
echo "After booting, select 'GNOME' session at the login screen"
