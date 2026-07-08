#!/usr/bin/bash

set -eoux pipefail

AKMODNV_PATH="${AKMODNV_PATH:-/tmp/akmods-nv-rpms}"

if [[ ! -d "${AKMODNV_PATH}" ]]; then
    echo "NVIDIA akmods RPM path not found: ${AKMODNV_PATH}"
    exit 1
fi

if [[ ! -f "${AKMODNV_PATH}/kmods/nvidia-vars" ]]; then
    echo "NVIDIA akmods metadata not found: ${AKMODNV_PATH}/kmods/nvidia-vars"
    exit 1
fi

source "${AKMODNV_PATH}/kmods/nvidia-vars"

echo "::group:: Install NVIDIA driver"

dnf -y install "${AKMODNV_PATH}"/ublue-os/ublue-os-nvidia-addons-*.rpm

dnf config-manager setopt fedora-nvidia.enabled=1 nvidia-container-toolkit.enabled=1
dnf config-manager setopt fedora-nvidia-lts.enabled=0 || true

if dnf repolist --enabled | grep -q "fedora-multimedia"; then
    dnf config-manager setopt fedora-multimedia.enabled=0
fi

dnf -y install \
    libnvidia-fbc \
    libnvidia-ml.i686 \
    libva-nvidia-driver \
    mesa-dri-drivers.i686 \
    mesa-filesystem.i686 \
    mesa-libEGL.i686 \
    mesa-libGL.i686 \
    mesa-libgbm.i686 \
    mesa-vulkan-drivers.i686 \
    nvidia-container-toolkit \
    nvidia-driver \
    nvidia-driver-cuda \
    nvidia-driver-cuda-libs.i686 \
    nvidia-driver-libs.i686 \
    nvidia-settings \
    "${AKMODNV_PATH}"/kmods/kmod-nvidia-"${KERNEL_VERSION}"-"${NVIDIA_AKMOD_VERSION}"."${DIST_ARCH}".rpm

KMOD_VERSION="$(rpm -q --queryformat '%{VERSION}' kmod-nvidia)"
DRIVER_VERSION="$(rpm -q --queryformat '%{VERSION}' nvidia-driver)"
if [[ "${KMOD_VERSION}" != "${DRIVER_VERSION}" ]]; then
    echo "NVIDIA kmod version ${KMOD_VERSION} does not match driver version ${DRIVER_VERSION}"
    exit 1
fi

dnf config-manager setopt fedora-nvidia.enabled=0 fedora-nvidia-lts.enabled=0 nvidia-container-toolkit.enabled=0

systemctl enable ublue-nvctk-cdi.service
semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

if [[ -f /usr/lib/dracut/dracut.conf.d/99-nvidia.conf ]]; then
    sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
    sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
fi

echo "::endgroup::"
