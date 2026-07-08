#!/usr/bin/bash

set -euo pipefail

echo "::group:: Cleanup build artifacts"

if command -v dnf5 >/dev/null 2>&1; then
    dnf5 -y clean all
elif command -v dnf >/dev/null 2>&1; then
    dnf -y clean all
fi

rm -rf \
    /run/dnf \
    /run/selinux-policy \
    /var/cache/dnf \
    /var/cache/libdnf5 \
    /var/lib/dnf \
    /var/tmp/*

echo "::endgroup::"
