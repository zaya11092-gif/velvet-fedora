# Velvet OS live ISO — compatible with livemedia-creator --no-virt
# See: https://weldr.io/lorax/livemedia-creator.html

url --url=https://download.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/
repo --name=updates --baseurl=https://download.fedoraproject.org/pub/fedora/linux/updates/41/Everything/x86_64/

%packages
@^workstation-product-environment
@gnome-desktop
livesys-scripts
anaconda-live
dracut-config-generic
dracut-live
-dracut-config-rescue
kernel
kernel-modules
kernel-modules-extra
grub2-efi
shim
shim-ia32
efibootmgr
syslinux
plymouth-system-theme
papirus-icon-theme
adw-gtk3
gnome-tweaks
gnome-shell-extension-user-theme
gnome-shell-extension-dash-to-dock
git
curl
wget
unzip
fastfetch
jetbrains-mono-fonts
%end

keyboard us
lang en_US.UTF-8
timezone UTC --utc
network --bootproto=dhcp --device=link --activate
services --enabled=NetworkManager,firewalld,bluetooth,livesys,livesys-late
selinux --enforcing
firewall --enabled
authselect --enableshadow --passalgo=sha512
rootpw --lock
user --name=velvet --password=velvet --plaintext --groups=wheel --gecos="Velvet Live User"

# livemedia-creator: no autopart; explicit root partition size
shutdown
bootloader --location=none
zerombr
clearpart --all --initlabel
reqpart
part / --size=12288 --fstype=ext4

%post --log=/root/velvet-post.log
#!/bin/bash
set -uxo pipefail

cat > /etc/os-release << 'EOF'
NAME="Velvet OS"
VERSION="1.0 (Slate)"
ID=velvet
ID_LIKE="fedora rhel centos"
VERSION_ID=1.0
PLATFORM_ID="platform:f41"
PRETTY_NAME="Velvet OS 1.0 (Slate)"
ANSI_COLOR="0;38;2;124;106;247"
HOME_URL="https://github.com/zaya11092-gif/velvet-fedora"
BUG_REPORT_URL="https://github.com/zaya11092-gif/velvet-fedora/issues"
EOF

ln -sf /etc/os-release /etc/velvet-release
echo "velvet-live" > /etc/hostname

# Live ISO: let dracut handle root mount
cat /dev/null > /etc/fstab
cat >> /etc/fstab << 'EOF'
vartmp   /var/tmp    tmpfs   defaults   0  0
EOF

install -d /usr/share/backgrounds/velvet
if [ -f /root/velvet-branding/velvet-dark.svg ]; then
  install -m644 /root/velvet-branding/velvet-dark.svg /usr/share/backgrounds/velvet/velvet-dark.svg
fi

# Optional theming (do not fail the whole build)
ORCHIS_DIR="/opt/velvet-themes/orchis"
if git clone --depth=1 https://github.com/vinceliuice/Orchis-theme.git "$ORCHIS_DIR"; then
  bash "$ORCHIS_DIR/install.sh" -c Dark -s compact --tweaks normal -d all || true
fi

VELVET_DCONF=/etc/dconf/db/local.d/00-velvet
mkdir -p "$(dirname "$VELVET_DCONF")"
cat > "$VELVET_DCONF" << 'EOF'
[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Orchis-Dark-Compact'
icon-theme='Papirus-Dark'
font-name='Cantarell 11'
monospace-font-name='JetBrains Mono 11'

[org/gnome/desktop/wallpaper]
picture-uri='file:///usr/share/backgrounds/velvet/velvet-dark.svg'
picture-uri-dark='file:///usr/share/backgrounds/velvet/velvet-dark.svg'

[org/gnome/shell/extensions/user-theme]
name='Orchis-Dark-Compact'
EOF

dconf update || true
systemctl enable gdm || true
rm -f /boot/*-rescue* || true
rm -f /etc/machine-id
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
