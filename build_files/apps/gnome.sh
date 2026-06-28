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
    file-roller \
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
    curl unzip python3 dconf \
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

echo "::group:: Install GNOME Extensions"

install_gnome_extension() {
    local extension_uuid="$1"
    local shell_version
    local tmpdir
    local download_url

    shell_version="$(gnome-shell --version | awk '{print $3}' | cut -d. -f1,2)"
    tmpdir="$(mktemp -d)"

    download_url="$(
        python3 - "${extension_uuid}" "${shell_version}" << 'PY'
import json
import sys
import urllib.parse
import urllib.request

uuid = sys.argv[1]
shell_version = sys.argv[2]
query = urllib.parse.urlencode({"uuid": uuid, "shell_version": shell_version})
with urllib.request.urlopen(f"https://extensions.gnome.org/extension-info/?{query}") as response:
    data = json.load(response)

print(urllib.parse.urljoin("https://extensions.gnome.org", data["download_url"]))
PY
    )"

    curl -fsSL "${download_url}" -o "${tmpdir}/${extension_uuid}.zip"
    rm -rf "/usr/share/gnome-shell/extensions/${extension_uuid}"
    mkdir -p "/usr/share/gnome-shell/extensions/${extension_uuid}"
    unzip -q "${tmpdir}/${extension_uuid}.zip" -d "/usr/share/gnome-shell/extensions/${extension_uuid}"
    chmod -R a+rX "/usr/share/gnome-shell/extensions/${extension_uuid}"
    rm -rf "${tmpdir}"
}

gnome_extensions=(
    "tilingshell@ferrarodomenico.com"
    "just-perfection-desktop@just-perfection"
    "dash-to-dock@micxgx.gmail.com"
)

for extension_uuid in "${gnome_extensions[@]}"; do
    install_gnome_extension "${extension_uuid}"
done

mkdir -p /etc/dconf/db/local.d
cat > /etc/dconf/db/local.d/00-gnome-extensions << 'GNOMEEXTENSIONS'
[org/gnome/shell]
enabled-extensions=['tilingshell@ferrarodomenico.com', 'just-perfection-desktop@just-perfection', 'dash-to-dock@micxgx.gmail.com']
GNOMEEXTENSIONS
dconf update

echo "GNOME extensions installed and enabled by default"
echo "::endgroup::"

echo "GNOME desktop installation complete!"
echo "After booting, select 'GNOME' session at the login screen"
