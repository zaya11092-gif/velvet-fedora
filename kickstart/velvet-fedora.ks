# Velvet OS live ISO (slim GNOME) for livemedia-creator --no-virt

url --url=https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/
repo --name=updates --baseurl=https://download.fedoraproject.org/pub/fedora/linux/updates/41/Everything/x86_64/

%packages
# Slimmer than @^workstation-product-environment to fit GitHub runner disk
@gnome-desktop
gdm
firefox
gnome-terminal
nautilus
livesys-scripts
anaconda-live
dracut-config-generic
dracut-live
-dracut-config-rescue
kernel
kernel-modules
grub2-efi
shim
efibootmgr
syslinux
plymouth-system-theme
papirus-icon-theme
gnome-tweaks
git
curl
wget
%end

keyboard us
lang en_US.UTF-8
timezone UTC --utc
network --bootproto=dhcp --device=link --activate
services --enabled=NetworkManager,firewalld,livesys,livesys-late
selinux --permissive
firewall --enabled
rootpw --lock
user --name=velvet --password=velvet --plaintext --groups=wheel --gecos="Velvet Live User"

shutdown
bootloader --location=none
zerombr
clearpart --all --initlabel
reqpart
part / --size=8192 --fstype=ext4

%post --log=/root/velvet-post.log
#!/bin/bash
set -uxo pipefail

cat > /etc/os-release << 'EOF'
NAME="Velvet OS"
VERSION="1.0 (Slate)"
ID=velvet
ID_LIKE="fedora"
VERSION_ID=1.0
PRETTY_NAME="Velvet OS 1.0 (Slate)"
ANSI_COLOR="0;38;2;124;106;247"
HOME_URL="https://github.com/zaya11092-gif/velvet-fedora"
EOF

echo "velvet-live" > /etc/hostname
cat /dev/null > /etc/fstab
echo 'vartmp   /var/tmp    tmpfs   defaults   0  0' >> /etc/fstab

install -d /usr/share/backgrounds/velvet
[ -f /root/velvet-branding/velvet-dark.svg ] && \
  install -m644 /root/velvet-branding/velvet-dark.svg /usr/share/backgrounds/velvet/velvet-dark.svg

mkdir -p /etc/dconf/db/local.d
cat > /etc/dconf/db/local.d/00-velvet << 'EOF'
[org/gnome/desktop/interface]
color-scheme='prefer-dark'
icon-theme='Papirus-Dark'

[org/gnome/desktop/wallpaper]
picture-uri='file:///usr/share/backgrounds/velvet/velvet-dark.svg'
picture-uri-dark='file:///usr/share/backgrounds/velvet/velvet-dark.svg'
EOF
dconf update || true
systemctl enable gdm || true
rm -f /boot/*-rescue* /etc/machine-id || true
touch /etc/machine-id

%end

%post --nochroot --log=/root/velvet-nochroot.log
#!/bin/bash
set -uxo pipefail
if [ -d /run/velvet-branding ] && [ -d /mnt/sysimage/root ]; then
  mkdir -p /mnt/sysimage/root/velvet-branding
  cp -a /run/velvet-branding/. /mnt/sysimage/root/velvet-branding/
fi
%end
