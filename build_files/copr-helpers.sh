#!/usr/bin/bash
set -euo pipefail

###############################################################################
# COPR Helper Functions
###############################################################################
# These helper functions follow the @ublue-os/bluefin pattern for managing
# COPR repositories in a safe, isolated manner.
###############################################################################

copr_install_isolated() {
    local copr_name="$1"
    shift
    local packages=("$@")

    if [[ ${#packages[@]} -eq 0 ]]; then
        echo "ERROR: No packages specified for copr_install_isolated"
        return 1
    fi

    repo_id="copr:copr.fedorainfracloud.org:${copr_name//\//:}"

    # Dynamically determine the fedora chroot (e.g., fedora-44-x86_64)
    local chroot="fedora-$(rpm -E %fedora)-$(uname -m)"

    echo "Installing ${packages[*]} from COPR $copr_name (isolated) using chroot $chroot"

    # Explicitly pass the chroot to the enable command
    dnf -y copr enable "$copr_name" "$chroot"
    dnf -y copr disable "$copr_name"
    dnf -y install --enablerepo="$repo_id" "${packages[@]}"

    echo "Installed ${packages[*]} from $copr_name"
}
