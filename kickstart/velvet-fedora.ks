# Velvet OS live ISO — based on lorax docs/fedora-livemedia.ks (F41)

xconfig --startxonboot
keyboard us
lang en_US.UTF-8
timezone UTC --utc
firewall --enabled
url --url=https://download.fedoraproject.org/pub/fedora/linux/releases/42/Everything/x86_64/os/
repo --name=updates --baseurl=https://download.fedoraproject.org/pub/fedora/linux/updates/42/Everything/x86_64/
network --bootproto=dhcp --device=link --activate
selinux --permissive
services --disabled=sshd --enabled=NetworkManager,livesys,livesys-late

shutdown
bootloader --location=none
zerombr
clearpart --all --initlabel
rootpw --lock
user --name=velvet --password=velvet --plaintext --groups=wheel --gecos="Velvet Live User"
reqpart
part / --size=5120 --fstype=ext4

%pre
PKGS=/tmp/arch-packages.ks
echo > "$PKGS"
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        cat >> "$PKGS" << 'PKGS_EOF'
%packages
@gnome-desktop
gdm
firefox
gnome-terminal
nautilus
shim
shim-ia32
grub2
grub2-efi
grub2-efi-ia32
grub2-efi-*-cdboot
efibootmgr
%end
PKGS_EOF
        ;;
esac
%end

%include /tmp/arch-packages.ks

%packages
livesys-scripts
@anaconda-tools
anaconda
anaconda-install-env-deps
anaconda-live
dracut-config-generic
dracut-live
kernel
kernel-modules
-@dial-up
-@input-methods
-@standard
-gfs2-utils
-gnome-boxes
papirus-icon-theme
gnome-tweaks
%end

%post --log=/root/velvet-post.log
systemctl enable tmp.mount
cat >> /etc/fstab << 'EOF'
vartmp   /var/tmp    tmpfs   defaults   0  0
EOF

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
rm -f /boot/*-rescue* /etc/machine-id || true
touch /etc/machine-id

install -d /usr/share/backgrounds/velvet
if [ -f /root/velvet-branding/velvet-dark.svg ]; then
  install -m644 /root/velvet-branding/velvet-dark.svg /usr/share/backgrounds/velvet/velvet-dark.svg
fi

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
%end

%post --nochroot --log=/root/velvet-nochroot.log
#!/bin/bash
set -uxo pipefail
if [ -d /run/velvet-branding ] && [ -d /mnt/sysimage/root ]; then
  mkdir -p /mnt/sysimage/root/velvet-branding
  cp -a /run/velvet-branding/. /mnt/sysimage/root/velvet-branding/
fi
%end
