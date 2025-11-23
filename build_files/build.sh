#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y zsh

# Install virt-manager stuff
dnf5 install -y \
    virt-manager \
    libvirt-daemon-kvm \
    qemu-kvm \
    libvirt-client \
    virt-install \
    bridge-utils \
    virt-viewer \
    libguestfs-tools \
    open-vm-tools \
    qemu-guest-agent \
    virt-install

# libvirt workarounds
dnf5 -y copr enable ublue-os/packages
dnf5 -y copr disable ublue-os/packages
dnf5 -y install --enablerepo="copr:copr.fedorainfracloud.org:ublue-os:packages" --setopt=install_weak_deps=False \
    ublue-os-libvirt-workarounds

### Configure dracut for Plymouth
# Copy dracut configuration to include Plymouth in initramfs
mkdir -p /etc/dracut.conf.d
cp /ctx/dracut.conf.d/plymouth.conf /etc/dracut.conf.d/

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

### Customize os-release
# This modifies the OS identification shown in system info, neofetch, etc.
# The canonical file is /usr/lib/os-release (symlinked from /etc/os-release)

sed -i 's/^NAME=.*/NAME="iZirc"/' /usr/lib/os-release
sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=\"${IMAGE_PRETTY_NAME}"|" /usr/lib/os-release
sed -i 's/^ID=.*/ID=izirc/' /usr/lib/os-release
sed -i '/^VERSION=/d' /usr/lib/os-release
sed -i '/^VARIANT=/d' /usr/lib/os-release
sed -i '/^VARIANT_ID=/d' /usr/lib/os-release
sed -i '/^HOME_URL=/d' /usr/lib/os-release
sed -i '/^CPE_NAME=/d' /usr/lib/os-release
echo 'HOME_URL="https://github.com/'"${GITHUB_REPOSITORY:-inffy/izirc}"'"' >> /usr/lib/os-release
sed -i '/^DOCUMENTATION_URL=/d' /usr/lib/os-release
echo 'DOCUMENTATION_URL="https://github.com/'"${GITHUB_REPOSITORY:-inffy/izirc}"'"' >> /usr/lib/os-release
sed -i '/^SUPPORT_URL=/d' /usr/lib/os-release
echo 'SUPPORT_URL="https://github.com/'"${GITHUB_REPOSITORY:-inffy/izirc}"'/issues"' >> /usr/lib/os-release
sed -i '/^BUG_REPORT_URL=/d' /usr/lib/os-release
echo 'BUG_REPORT_URL="https://github.com/'"${GITHUB_REPOSITORY:-inffy/izirc}"'/issues"' >> /usr/lib/os-release
sed -i '/^LOGO=/d' /usr/lib/os-release
# echo 'LOGO="izirc"' >> /usr/lib/os-release
