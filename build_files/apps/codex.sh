#!/usr/bin/env bash

set -oue pipefail

echo "::group:: Install Codex CLI"

codex_package_dir="/usr/lib/codex"
install -d -m 0755 "${codex_package_dir}" /usr/bin

curl -fsSL https://chatgpt.com/codex/install.sh | \
    CODEX_NON_INTERACTIVE=1 \
    CODEX_INSTALL_DIR=/usr/bin \
    CODEX_HOME="${codex_package_dir}" \
    sh

chmod -R a+rX "${codex_package_dir}"

/usr/bin/codex --version

echo "Codex CLI installed successfully"
echo "::endgroup::"
