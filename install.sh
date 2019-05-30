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
mkdir /etc/systemd/system/sysinit.target.wants
ln -sf /usr/lib/systemd/system/systemd-timesyncd.service /etc/systemd/system/dbus-org.freedesktop.timesync1.service
ln -sf /usr/lib/systemd/system/systemd-timesyncd.service /etc/systemd/system/sysinit.target.wants/systemd-timesyncd.service

echo_sleep "Generate locale..."
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen

echo_sleep "Set locale..."
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo_sleep "Set hostname..."
echo $HOSTNAME > /etc/hostname

echo "Enter password for root"
passwd

echo_sleep "Create user..."
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
useradd -g wheel -m $NEWUSER
echo "Enter password for $NEWUSER"
passwd $NEWUSER

echo_sleep "Install grub..."
pacman -S --noconfirm grub os-prober
grub-install $DISK

echo_sleep "Create grub.cfg..."
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

cd /opt/arch_install
echo_sleep "Install packages..."
pacman --noconfirm -S $(cat packages)
usermod -aG adbusers $NEWUSER

echo_sleep "Remove gsfonts..."
pacman --noconfirm -Rdd gsfonts

echo_sleep "Setup networkmanager..."
ln -sf /usr/lib/systemd/system/NetworkManager.service /etc/systemd/system/multi-user.target.wants/NetworkManager.service
ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
mkdir /etc/systemd/system/network-online.target.wants
ln -sf /usr/lib/systemd/system/NetworkManager-wait-online.service /etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service

echo_sleep "Setup cron..."
cp crontab "/var/spool/cron/$NEWUSER"
ln -sf /usr/lib/systemd/system/cronie.service /etc/systemd/system/multi-user.target.wants/cronie.service

echo_sleep "Setup devmon..."
sed -i 's/ARGS=""/ARGS="-s"/' /etc/conf.d/devmon
ln -sf /usr/lib/systemd/system/devmon@.service "/etc/systemd/system/multi-user.target.wants/devmon@$NEWUSER.service"

echo_sleep "Setup fstrim..."
mkdir /etc/systemd/system/timers.target.wants
ln -sf /usr/lib/systemd/system/fstrim.timer /etc/systemd/system/timers.target.wants/fstrim.timer

echo_sleep "Setup tlp..."
ln -sf /usr/lib/systemd/system/tlp.service /etc/systemd/system/multi-user.target.wants/tlp.service
mkdir /etc/systemd/system/sleep.target.wants
ln -sf /usr/lib/systemd/system/tlp-sleep.service /etc/systemd/system/sleep.target.wants/tlp-sleep.service

echo_sleep "Fix screen tearing..."
cp 20-intel.conf /etc/X11/xorg.conf.d/20-intel.conf

echo_sleep "Disable pc speaker..."
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

echo_sleep "Limit systemd journald log size..."
sed -i 's/#SystemMaxUse=/SystemMaxUse=50M/' /etc/systemd/journald.conf

echo_sleep "Disable coredump..."
sed -i 's/#Storage=external/Storage=none/' /etc/systemd/coredump.conf

echo "Setup gnome-keyring unlock on login..."
sed -i '/auth       include      system-local-login/a auth       optional     pam_gnome_keyring.so' /etc/pam.d/login
sed -i '/session    include      system-local-login/a session    optional     pam_gnome_keyring.so auto_start' /etc/pam.d/login

echo_sleep "Setup data partition..."
mkdir /mnt/PODACI
chown $NEWUSER:wheel /mnt/PODACI
cat fstab >> /etc/fstab

chown -R $NEWUSER:wheel /opt/arch_install
cd /opt/arch_install

echo_sleep "Install yay..."
sed -i 's/#Color/Color/' /etc/pacman.conf
wget "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay" -O PKGBUILD
sudo -u $NEWUSER sh -c "yes | makepkg -si"

echo_sleep "Install AUR packages..."
# Dropbox public key
sudo -u $NEWUSER sh -c "gpg --recv-keys 1C61A2656FB57B7E4DE0F4C1FC918B335044912E"
sudo -u $NEWUSER sh -c "yes | yay -S --nodiffmenu --nocleanmenu --noprovides \$(cat packages_aur)"

cd /opt
rm -rf /opt/arch_install

echo_sleep "Clean pacman/yay cache..."
rm -rf /var/cache/pacman/pkg/*
rm -rf "/home/$NEWUSER/.cache/yay/*"

echo_sleep "Set zsh as user shell..."
chsh -s /usr/bin/zsh $NEWUSER

echo_sleep "Fetch configs for user..."
cd "/home/$NEWUSER"
sudo -u $NEWUSER git init
sudo -u $NEWUSER git remote add origin https://github.com/wooque/configs
sudo -u $NEWUSER git fetch --all
sudo -u $NEWUSER git reset --hard origin/master
sudo -u $NEWUSER git branch --set-upstream-to=origin/master master
sudo -u $NEWUSER git remote set-url origin git@github.com:wooque/configs.git
