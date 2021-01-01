#!/bin/bash
echo_sleep () { echo "$1"; sleep 1; }

BOOT_DISK="/dev/sda"
NEWUSER="vuk"
NEWUSER_GROUPS="docker"
TIMEZONE="/usr/share/zoneinfo/Europe/Belgrade"
HOSTNAME="battlestation"
LOCALE="en_US.UTF-8"
PACKAGES_BOOT="grub intel-ucode"
PACKAGES_BASE="nano man-db bash-completion cronie tlp networkmanager libva-intel-driver git"
PACKAGES_DE="gdm gnome-control-center gnome-terminal nautilus gnome-backgrounds gnome-keyring gnome-tweaks chrome-gnome-shell"
PACKAGES_FONTS="ttf-liberation ttf-dejavu ttf-droid noto-fonts-emoji"
PACKAGES_APPS="chromium gedit gnome-calculator gnome-screenshot file-roller eog evince mpv transmission-gtk gimp libreoffice-fresh meld"
PACKAGES_UTILS="z htop ncdu rsync p7zip bluez-utils"
PACKAGES_DEV="docker-compose nodejs npm code tk"
PACKAGES_VM="qemu samba"
PACKAGES_AUR="dropbox viber postman-bin tableplus"
SERVICES="gdm NetworkManager bluetooth cronie tlp fstrim.timer"
CRON="0 11,17,23 * * * \$HOME/.scripts/backup"
FSTAB=("LABEL=PODACI /mnt/PODACI ext4 noatime,x-gvfs-show 0 0")

echo_sleep "Setup time..."
ln -sf "$TIMEZONE" /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd

echo_sleep "Setup locale..."
sed -i "s/#$LOCALE/$LOCALE/" /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

echo_sleep "Set hosts..."
echo "$HOSTNAME" > /etc/hostname
cat >> /etc/hosts << EOF
127.0.0.1 localhost
::1 localhost
EOF

echo "Enter password for root"
passwd

echo_sleep "Create user..."
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
useradd -g wheel -m $NEWUSER
echo "Enter password for $NEWUSER"
passwd $NEWUSER

echo_sleep "Install bootloader..."
pacman -S --noconfirm $PACKAGES_BOOT
grub-install $BOOT_DISK
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo_sleep "Install base packages..."
pacman --noconfirm -S $PACKAGES_BASE

echo_sleep "Install desktop environment..."
pacman --noconfirm -S $PACKAGES_DE

echo_sleep "Install fonts..."
pacman --noconfirm -S $PACKAGES_FONTS

echo_sleep "Install apps..."
pacman --noconfirm -S $PACKAGES_APPS

echo_sleep "Install utils..."
pacman --noconfirm -S $PACKAGES_UTILS

echo_sleep "Install dev packages..."
pacman --noconfirm -S $PACKAGES_DEV

echo_sleep "Install virtual machine packages..."
pacman --noconfirm -S $PACKAGES_VM

echo_sleep "Setup user groups..."
usermod -aG "$NEWUSER_GROUPS" "$NEWUSER"

echo_sleep "Enable services..."
systemctl enable $SERVICES

echo_sleep "Setup cron..."
echo "$CRON" >> "/var/spool/cron/$NEWUSER"

echo_sleep "Setup systemd tweaks..."
sed -i 's/#SystemMaxUse=/SystemMaxUse=50M/' /etc/systemd/journald.conf
sed -i 's/#Storage=external/Storage=none/' /etc/systemd/coredump.conf

echo_sleep "Setup fonts..."
cat >> /etc/fonts/local.conf << EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <include ignore_missing="yes">conf.d</include>
  <match target="font">
    <edit name="antialias" mode="assign">
      <bool>true</bool>
    </edit>
  </match>
  <match target="font">
    <edit name="rgba" mode="assign">
      <const>rgb</const>
    </edit>
  </match>
  <match target="font">
    <edit name="lcdfilter" mode="assign">
      <const>lcddefault</const>
    </edit>
  </match>
  <match target="font">
    <edit name="hinting" mode="assign">
      <bool>true</bool>
    </edit>
  </match>
  <match target="font">
    <edit name="hintstyle" mode="assign">
      <const>hintslight</const>
    </edit>
  </match>
  <match target="font">
    <edit name="autohint" mode="assign">
      <bool>false</bool>
    </edit>
  </match>
  <match target="pattern">
    <edit name="dpi" mode="assign">
      <double>96</double>
    </edit>
  </match>
  <alias>
    <family>serif</family>
    <prefer><family>Liberation Serif</family></prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer><family>Liberation Sans</family></prefer>
  </alias>
  <alias>
    <family>sans</family>
    <prefer><family>Liberation Sans</family></prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer><family>Liberation Mono</family></prefer>
  </alias>
</fontconfig>
EOF

echo_sleep "Setup mounts..."
for f in "${FSTAB[@]}"; do
dir=$(echo "$f" | cut -d ' ' -f2)
mkdir "$dir"
chown $NEWUSER:wheel "$dir"
echo "$f" >> /etc/fstab
done

echo_sleep "Fetch dotfiles..."
cd "/home/$NEWUSER"
sudo -u $NEWUSER git init
sudo -u $NEWUSER git remote add origin https://github.com/wooque/dotfiles
sudo -u $NEWUSER git fetch --set-upstream origin master
sudo -u $NEWUSER git reset --hard origin/master
sudo -u $NEWUSER git remote set-url origin git@github.com:wooque/dotfiles.git

mkdir /tmp/aur
chown $NEWUSER:wheel /tmp/aur
cd /tmp/aur

echo_sleep "Install yay..."
sed -i 's/#Color/Color/' /etc/pacman.conf
curl "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay-bin" -o PKGBUILD
sudo -u $NEWUSER sh -c "yes | makepkg -si"

echo_sleep "Install AUR packages..."
sudo -u $NEWUSER sh -c "yes | yay -S --nodiffmenu --nocleanmenu --noprovides $PACKAGES_AUR"

rm -rf /root/install.sh

echo_sleep "Clean pacman/yay cache..."
rm -rf /var/cache/pacman/pkg/*
rm -rf "/home/$NEWUSER/.cache/yay"

