#!/bin/bash

set -ouex pipefail

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

dnf -y install dnf5-plugins
dnf config-manager setopt terra.enabled=1
dnf -y install terra-release

bash /ctx/apps/install-apps.sh

## GNOME extensions not packaged in Fedora
mosaic_extension_uuid="gnome-mosaic@jardon.github.com"
mosaic_extension_dir="/usr/share/gnome-shell/extensions/${mosaic_extension_uuid}"
mosaic_extension_tmpdir="$(mktemp -d)"
curl -fsSL \
    "https://extensions.gnome.org/download-extension/${mosaic_extension_uuid}.shell-extension.zip?version_tag=71184" \
    -o "${mosaic_extension_tmpdir}/mosaic.zip"
rm -rf "${mosaic_extension_dir}"
mkdir -p "${mosaic_extension_dir}"
unzip -q "${mosaic_extension_tmpdir}/mosaic.zip" -d "${mosaic_extension_dir}"
find "${mosaic_extension_dir}" -type d -exec chmod 0755 {} \;
find "${mosaic_extension_dir}" -type f -exec chmod 0644 {} \;
rm -rf "${mosaic_extension_tmpdir}"

## GNOME extension defaults
mkdir -p /etc/dconf/db/local.d
mapfile -t fabyos_gnome_extensions < <(
    printf '%s\n' \
        'appindicatorsupport@rgcjonas.gmail.com' \
        'blur-my-shell@aunetx' \
        'dash-to-panel@jderose9.github.com' \
        'gnome-mosaic@jardon.github.com' \
        'just-perfection-desktop@just-perfection'
)
fabyos_gnome_extensions_value="$(
    printf "'%s'\n" "${fabyos_gnome_extensions[@]}" |
        awk 'NF && !seen[$0]++ { values = values sep $0; sep = ", " } END { print "[" values "]" }'
)"
cat > /etc/dconf/db/local.d/00-fabyos-gnome-extensions << 'GNOMEEXTENSIONS'
[org/gnome/shell]
GNOMEEXTENSIONS
printf 'enabled-extensions=%s\n' "$fabyos_gnome_extensions_value" >> /etc/dconf/db/local.d/00-fabyos-gnome-extensions
dconf update

## Theme defaults
mkdir -p /usr/share/icons/default
cat > /usr/share/icons/default/index.theme << 'THEMEDEFAULTS'
[Icon Theme]
Inherits=Bibata-Modern-Classic
THEMEDEFAULTS

mkdir -p /etc/skel/.config/gtk-3.0 /etc/skel/.config/gtk-4.0
cat > /etc/skel/.config/gtk-3.0/settings.ini << 'GTKSETTINGS'
[Settings]
gtk-icon-theme-name=Papirus
gtk-cursor-theme-name=Bibata-Modern-Classic
GTKSETTINGS
cp /etc/skel/.config/gtk-3.0/settings.ini /etc/skel/.config/gtk-4.0/settings.ini



## Fish installation and configuration
dnf -y install fish
sed -i 's|^SHELL=/bin/bash|SHELL=/usr/bin/fish|' /etc/default/useradd
mkdir -p /usr/share/fish/
mkdir -p /etc/skel/.config/
cp -r /ctx/defaults/fish/ /usr/share/
cp -r /ctx/dotfiles/fish/ /etc/skel/.config


## Change logo
cp /ctx/res/logo/logo.png /usr/share/plymouth/themes/spinner/watermark.png
cp /ctx/res/logo/logo.png /usr/share/plymouth/themes/spinner/bgrt-fallback.png

cp /ctx/res/logo/logo.png /usr/share/pixmaps/system-logo-white.png

## Brand boot loader entries that may already exist in the base image
if [ -d /boot/loader/entries ]; then
    find /boot/loader/entries -type f -name '*.conf' -exec \
        sed -i -E 's/^(title[[:space:]]+)Fedora( Linux)?/\1FabyOS/' {} +
fi


## Rebuild initramfs to apply the new boot logo
KVER=$(cd /usr/lib/modules && echo *)
dracut -vf --no-hostonly --add ostree /usr/lib/modules/$KVER/initramfs.img "$KVER"

## Setup Podman
dnf -y install docker-compose podman-docker
echo 'L+ /var/run/docker.sock - - - - /run/podman/podman.sock' > /usr/lib/tmpfiles.d/podman-docker-socket.conf

systemctl enable podman.socket

rm -f /etc/yum.repos.d/terra*.repo

## System setup
cp -r /ctx/system-setup /usr/libexec/
chmod +x /usr/libexec/system-setup/first-boot.sh

cp /ctx/system-setup/first-boot.service /usr/lib/systemd/system/
systemctl enable first-boot.service

# 1. Install the setup script
cp -r /ctx/users-setup /usr/libexec/
chmod +x /usr/libexec/users-setup/first-login.sh

chmod +x /usr/libexec/users-setup/faby02/setup.sh
chmod +x /usr/libexec/users-setup/faby02/restore.sh

# 2. Install the user service
mkdir -p /usr/lib/systemd/user/
cp /ctx/users-setup/first-login.service /usr/lib/systemd/user/

# 3. Enable the service globally for all users
systemctl --global enable first-login.service

bash /ctx/cleanup.sh
