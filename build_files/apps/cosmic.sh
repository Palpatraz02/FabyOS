#!/usr/bin/bash

set -eoux pipefail

# shellcheck source=/dev/null
source /ctx/apps/copr-helpers.sh

echo "::group:: Install COSMIC Desktop"

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

echo "::endgroup::"

echo "::group:: Configure Display Manager"

systemctl enable -f cosmic-greeter.service
systemctl set-default graphical.target

mkdir -p /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/cosmic.desktop << 'COSMICDESKTOP'
[Desktop Entry]
Name=COSMIC
Comment=COSMIC Desktop Environment
Exec=cosmic-session
Type=Application
DesktopNames=COSMIC
COSMICDESKTOP

echo "::endgroup::"

echo "::group:: Install Desktop Utilities"

dnf -y install \
    NetworkManager-tui \
    NetworkManager-wifi \
    NetworkManager-openvpn \
    NetworkManager-vpnc \
    NetworkManager-l2tp \
    accountsservice \
    alsa-utils \
    bluez \
    bluez-obexd \
    bolt \
    brightnessctl \
    cups \
    cups-pk-helper \
    desktop-file-utils \
    firewalld \
    firewall-config \
    fprintd \
    geoclue2 \
    google-noto-color-emoji-fonts \
    google-noto-sans-fonts \
    google-noto-sans-mono-fonts \
    google-noto-serif-fonts \
    gvfs \
    gvfs-gphoto2 \
    gvfs-mtp \
    gvfs-smb \
    iio-sensor-proxy \
    liberation-fonts \
    pipewire \
    pipewire-alsa \
    pipewire-pulseaudio \
    playerctl \
    polkit \
    rtkit \
    shared-mime-info \
    switcheroo-control \
    system-config-printer \
    udisks2 \
    upower \
    wireplumber \
    wl-clipboard \
    xdg-desktop-portal \
    xdg-desktop-portal-cosmic \
    xdg-desktop-portal-gtk \
    xdg-user-dirs \
    xdg-utils \
    xorg-x11-server-Xwayland \
    avahi \
    nss-mdns \
    fwupd \
    usbutils \
    pciutils \

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups
systemctl enable firewalld
systemctl enable switcheroo-control

echo "::endgroup::"
