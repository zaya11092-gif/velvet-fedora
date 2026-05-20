# Velvet OS — Fedora Workstation live/install ISO
# Built with: livemedia-creator --make-iso --ks=velvet-fedora.ks

%global distro Fedora
%global releasever 41
%global product_name Velvet OS
%global product_version 1.0

url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-41&arch=x86_64
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f41&arch=x86_64

%packages
@^workstation-product-environment
@gnome-desktop
@fonts
@multimedia
plymouth-system-theme
plymouth-plugin-script
papirus-icon-theme
adw-gtk3
gnome-tweaks
gnome-shell-extension-user-theme
gnome-shell-extension-dash-to-dock
dconf-editor
git
curl
wget
jq
fastfetch
jetbrains-mono-fonts
google-noto-sans-vf-fonts
google-noto-sans-mono-vf-fonts
ffmpeg-libs
gstreamer1-plugins-good
gstreamer1-plugins-bad-free
%end

%addon com_redhat_kdump
%end

bootloader --timeout=2
zerombr
clearpart --all --initlabel
autopart --type=plain --nohome
part / --fstype=ext4 --size=8192 --grow

keyboard us
lang en_US.UTF-8
timezone UTC --utc
network --bootproto=dhcp --device=link --activate
services --enabled=NetworkManager,firewalld,bluetooth,sshd
selinux --enforcing
firewall --enabled
authselect --enableshadow --passalgo=sha512
rootpw --lock
user --name=velvet --password=velvet --plaintext --groups=wheel --gecos="Velvet Live User"

%anaconda
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

liveimg --size=12288
liveinst
reboot

%post --log=/root/velvet-post.log
#!/bin/bash
set -euxo pipefail

# Branding
cat > /etc/os-release << 'EOF'
NAME="Velvet OS"
VERSION="1.0 (Slate)"
ID=velvet
ID_LIKE="fedora rhel centos"
VERSION_ID=1.0
PLATFORM_ID="platform:f41"
PRETTY_NAME="Velvet OS 1.0 (Slate)"
ANSI_COLOR="0;38;2;124;106;247"
HOME_URL="https://github.com/"
DOCUMENTATION_URL="https://docs.fedoraproject.org/"
BUG_REPORT_URL="https://github.com/"
REDHAT_SUPPORT_PRODUCT="Velvet OS"
REDHAT_SUPPORT_PRODUCT_VERSION=1.0
EOF

ln -sf /etc/os-release /etc/velvet-release
echo "Velvet OS 1.0" > /etc/issue
echo "Velvet OS 1.0" > /etc/issue.net

# Hostname for live session
echo "velvet-live" > /etc/hostname

# Plymouth — dark moon theme
alternatives --set default-pl-theme /usr/share/plymouth/themes/moon/moon.plymouth 2>/dev/null || true
plymouth-set-default-theme moon 2>/dev/null || true

# Orchis GTK (sleek dark compact)
ORCHIS_DIR="/opt/velvet-themes/orchis"
mkdir -p "$(dirname "$ORCHIS_DIR")"
git clone --depth=1 https://github.com/vinceliuice/Orchis-theme.git "$ORCHIS_DIR"
bash "$ORCHIS_DIR/install.sh" -c Dark -s compact --tweaks normal -d all

# Default dconf for live user + skeleton
VELVET_DCONF=/etc/dconf/db/local.d/00-velvet
mkdir -p "$(dirname "$VELVET_DCONF")"
cat > "$VELVET_DCONF" << 'EOF'
[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Orchis-Dark-Compact'
icon-theme='Papirus-Dark'
cursor-theme='Adwaita'
font-name='Inter 11'
document-font-name='Inter 11'
monospace-font-name='JetBrains Mono 11'
enable-hot-corners=false

[org/gnome/desktop/wallpaper]
picture-uri='file:///usr/share/backgrounds/velvet/velvet-dark.svg'
picture-uri-dark='file:///usr/share/backgrounds/velvet/velvet-dark.svg'

[org/gnome/desktop/background]
color-shading-type='solid'
primary-color='#121218'
secondary-color='#1a1a24'
picture-uri='file:///usr/share/backgrounds/velvet/velvet-dark.svg'
picture-uri-dark='file:///usr/share/backgrounds/velvet/velvet-dark.svg'

[org/gnome/shell]
favorite-apps=['org.gnome.Nautilus.desktop', 'org.gnome.firefox.desktop', 'org.gnome.Console.desktop', 'org.gnome.Software.desktop']
disable-user-extensions=false

[org/gnome/shell/extensions/user-theme]
name='Orchis-Dark-Compact'

[org/gnome/shell/extensions/dash-to-dock]
dock-position='BOTTOM'
extend-height=false
transparency-mode='FIXED'
background-opacity=0.55
custom-theme-shrink=true

[org/gnome/desktop/wm/preferences]
button-layout='appmenu:minimize,maximize,close'

[org/gnome/mutter]
center-new-windows=true
dynamic-workspaces=true

[org/gnome/settings-daemon/plugins/power]
ambient-enabled=false
EOF

# Wallpaper
install -d /usr/share/backgrounds/velvet
if [ -f /root/velvet-branding/velvet-dark.svg ]; then
  install -m644 /root/velvet-branding/velvet-dark.svg /usr/share/backgrounds/velvet/velvet-dark.svg
fi

# Inter font (Google Fonts tarball)
INTER_DIR="/opt/velvet-themes/inter"
mkdir -p "$INTER_DIR"
curl -fsSL -o /tmp/inter.zip "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
unzip -qo /tmp/inter.zip -d "$INTER_DIR"
install -Dm644 "$INTER_DIR"/extras/ttf/Inter-*.ttf /usr/share/fonts/velvet-inter/ 2>/dev/null || \
  install -Dm644 "$INTER_DIR"/InterDesktop/*.ttf /usr/share/fonts/velvet-inter/ 2>/dev/null || true
fc-cache -f /usr/share/fonts/velvet-inter 2>/dev/null || true

# Update dconf if Inter installed
if fc-list | grep -qi inter; then
  sed -i "s/Inter 11/Inter 10/" "$VELVET_DCONF" || true
fi

dconf update
systemctl enable gdm

# Fastfetch config
mkdir -p /etc/xdg/fastfetch
cat > /etc/xdg/fastfetch/config.jsonc << 'EOF'
{
  "logo": { "type": "builtin", "builtin": "fedora" },
  "display": { "separator": "  " },
  "modules": [
    "title:Velvet OS",
    "os",
    "kernel",
    "uptime",
    "packages",
    "shell",
    "de",
    "wm",
    "terminal",
    "cpu",
    "gpu",
    "memory",
    "disk",
    "colors"
  ]
}
EOF

%end

%post --nochroot --log=/root/velvet-nochroot.log
#!/bin/bash
set -euxo pipefail
if [ -d /run/velvet-branding ] && [ -d /mnt/sysimage/root ]; then
  mkdir -p /mnt/sysimage/root/velvet-branding
  cp -a /run/velvet-branding/. /mnt/sysimage/root/velvet-branding/
fi
%end
