#!/usr/bin/env bash

set -oue pipefail

echo "::group:: Install Zed"

case "$(uname -m)" in
    x86_64 | amd64)
        zed_arch="x86_64"
        ;;
    aarch64 | arm64)
        zed_arch="aarch64"
        ;;
    *)
        echo "Unsupported architecture for Zed: $(uname -m)" >&2
        exit 1
        ;;
esac

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

zed_app_dir="/opt/zed.app"
zed_archive="${tmpdir}/zed-linux-${zed_arch}.tar.gz"
zed_download_url="https://cloud.zed.dev/releases/stable/latest/download?asset=zed&arch=${zed_arch}&os=linux&source=docs"

curl -fL "${zed_download_url}" -o "${zed_archive}"

rm -rf "${zed_app_dir}"
tar -xzf "${zed_archive}" -C /opt

if [ ! -x "${zed_app_dir}/bin/zed" ]; then
    echo "Zed binary was not found after extracting ${zed_archive}" >&2
    exit 1
fi

ln -sf "${zed_app_dir}/bin/zed" /usr/bin/zed

install -D -m 0644 \
    "${zed_app_dir}/share/applications/dev.zed.Zed.desktop" \
    /usr/share/applications/dev.zed.Zed.desktop

sed -i \
    -e "s|Icon=zed|Icon=${zed_app_dir}/share/icons/hicolor/512x512/apps/zed.png|g" \
    -e "s|Exec=zed|Exec=${zed_app_dir}/bin/zed|g" \
    /usr/share/applications/dev.zed.Zed.desktop

echo "Zed installed successfully"
echo "::endgroup::"
