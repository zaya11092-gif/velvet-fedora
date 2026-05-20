# Velvet OS — automated install kickstart (for mkksiso / installer ISO)

url --url=https://download.fedoraproject.org/pub/fedora/linux/releases/42/Everything/x86_64/os/
repo --name=updates --baseurl=https://download.fedoraproject.org/pub/fedora/linux/updates/42/Everything/x86_64/
keyboard us
lang en_US.UTF-8
timezone UTC --utc
network --bootproto=dhcp --device=link --activate
selinux --enforcing
firewall --enabled
clearpart --all --initlabel
autopart
bootloader --location=mbr
rootpw --lock
user --name=velvet --password=velvet --plaintext --groups=wheel --gecos="Velvet User"

%packages
@gnome-desktop
gdm
firefox
gnome-terminal
nautilus
papirus-icon-theme
gnome-tweaks
%end

%post
cat > /etc/os-release << 'EOF'
NAME="Velvet OS"
VERSION="1.0 (Slate)"
ID=velvet
ID_LIKE="fedora"
VERSION_ID=1.0
PRETTY_NAME="Velvet OS 1.0 (Slate)"
EOF
%end
