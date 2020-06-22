#!/bin/bash

echo_sleep () {
    echo $1
    sleep 1
}

DISK=${1:-"/dev/sda"}
NEWUSER=${2:-"vuk"}
TIMEZONE="/usr/share/zoneinfo/Europe/Belgrade"
HOSTNAME="battlestation"

echo_sleep "Set timezone..."
ln -sf $TIMEZONE /etc/localtime

echo_sleep "Sync hardware clock..."
hwclock --systohc

echo_sleep "Setup network time sync..."
systemctl enable systemd-timesyncd.service

echo_sleep "Generate locale..."
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen

echo_sleep "Set locale..."
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo_sleep "Set hostname..."
echo $HOSTNAME > /etc/hostname

echo_sleep "Set hosts..."
cat >> /etc/hosts << EOF
127.0.0.1	localhost
::1		    localhost
EOF

echo "Enter password for root"
passwd

echo_sleep "Create user..."
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
useradd -g wheel -m $NEWUSER
echo "Enter password for $NEWUSER"
passwd $NEWUSER

echo_sleep "Install grub..."
pacman -S --noconfirm grub
grub-install $DISK

echo_sleep "Create grub.cfg..."
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/quiet/quiet udev.log_priority=3 vt.global_cursor_default=0 intel_iommu=off/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo_sleep "Install packages..."
pacman --noconfirm -S $(cat /root/arch_install/packages)
usermod -aG docker $NEWUSER

echo_sleep "Setup iwd..."
cat >> /etc/iwd/main.conf << EOF
[General]
EnableNetworkConfiguration=true
[Network]
NameResolvingService=resolvconf
EOF
systemctl enable iwd.service

echo_sleep "Setup cron..."
cat >> "/var/spool/cron/$NEWUSER" << EOF
0   11,17,23  *   *   *   "\$HOME/.scripts/backup"
0   23  *   *   *   cu="\$(checkupdates)"; if [[ -n "\$cu" ]]; then echo "\$cu" > "\$HOME/updates.log"; fi
EOF
systemctl enable cronie.service

echo_sleep "Setup devmon..."
sed -i 's/ARGS=""/ARGS="-s"/' /etc/conf.d/devmon
systemctl enable "devmon@$NEWUSER.service"

echo_sleep "Setup fstrim..."
systemctl enable fstrim.timer

echo_sleep "Setup tlp..."
systemctl enable tlp.service

echo_sleep "Setup bluetooth..."
systemctl enable bluetooth.service
sed -i 's/#AutoEnable=false/AutoEnable=true/' /etc/bluetooth/main.conf

echo_sleep "Fix screen tearing..."
cat >> /etc/X11/xorg.conf.d/20-intel.conf << EOF
Section "Device"
  Identifier  "Intel Graphics"
  Driver      "intel"
  Option      "TearFree" "true"
EndSection
EOF

echo_sleep "Disable pc speaker..."
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

echo_sleep "Limit systemd journald log size..."
sed -i 's/#SystemMaxUse=/SystemMaxUse=50M/' /etc/systemd/journald.conf

echo_sleep "Disable coredump..."
sed -i 's/#Storage=external/Storage=none/' /etc/systemd/coredump.conf

echo_sleep "Disable systemd-homed/userdbd..."
systemctl mask systemd-homed.service
systemctl mask systemd-userdbd.socket

echo_sleep "Setup data partition..."
mkdir /mnt/PODACI
chown $NEWUSER:wheel /mnt/PODACI
cat >> /etc/fstab << EOF
LABEL=PODACI                                /mnt/PODACI ext4        noatime,x-gvfs-show 0 0
EOF

echo_sleep "Setup autologin..."
mkdir  /etc/systemd/system/getty@tty1.service.d
cat >> /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
Type=simple
ExecStart=
ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin $NEWUSER --noclear %I \$TERM
EOF

echo_sleep "Set zsh as user shell..."
chsh -s /usr/bin/zsh $NEWUSER

echo_sleep "Fetch dotfiles..."
cd "/home/$NEWUSER"
sudo -u $NEWUSER git init
sudo -u $NEWUSER git remote add origin https://github.com/wooque/dotfiles
sudo -u $NEWUSER git fetch --all
sudo -u $NEWUSER git reset --hard origin/master
sudo -u $NEWUSER git branch --set-upstream-to=origin/master master
sudo -u $NEWUSER git remote set-url origin git@github.com:wooque/dotfiles.git

mkdir /tmp/aur
chown $NEWUSER:wheel /tmp/aur
cd /tmp/aur

echo_sleep "Install yay..."
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i "s/PKGEXT='.pkg.tar.xz'/PKGEXT='.pkg.tar'/" /etc/makepkg.conf
curl "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay-bin" -o PKGBUILD
sudo -u $NEWUSER sh -c "yes | makepkg -si"

echo_sleep "Install AUR packages..."
sudo -u $NEWUSER sh -c "yes | yay -S --nodiffmenu --nocleanmenu --noprovides $(cat /root/arch_install/packages_aur | tr '\n' ' ')"

rm -rf /root/arch_install

echo_sleep "Clean pacman/yay cache..."
rm -rf /var/cache/pacman/pkg/*
rm -rf "/home/$NEWUSER/.cache/yay/*"

