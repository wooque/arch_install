#!/bin/bash

echo_sleep () { 
    echo $1 
    sleep 1
}

echo_sleep "Set timezone..."
ln -sf /usr/share/zoneinfo/Europe/Belgrade /etc/localtime

echo_sleep "Sync hardware clock..."
hwclock --systohc

echo_sleep "Setup network time sync..."
mkdir /etc/systemd/system/sysinit.target.wants
ln -sf /usr/lib/systemd/system/systemd-timesyncd.service /etc/systemd/system/sysinit.target.wants/systemd-timesyncd.service

echo_sleep "Generate locale..."
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen

echo_sleep "Set locale..."
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo_sleep "Set hostname..."
echo "battlestation" > /etc/hostname

echo "Enter password for root"
passwd

echo_sleep "Create user..."
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
useradd -g wheel -m vuk
echo "Enter password for vuk"
passwd vuk

echo_sleep "Install grub..."
pacman -S --noconfirm grub os-prober
grub-install /dev/sda

echo_sleep "Create grub.cfg..."
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="elevator=deadline"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

cd /opt/arch_install
echo_sleep "Install packages..."
pacman --noconfirm -S $(cat packages)
usermod -a -G docker vuk

echo_sleep "Setup lighdm..."
cp lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
ln -sf /usr/lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service

echo_sleep "Setup cron..."
cp crontab /var/spool/cron/vuk
ln -sf /usr/lib/systemd/system/cronie.service /etc/systemd/system/multi-user.target.wants/cronie.service

echo_sleep "Setup networkmanager..."
ln -sf /usr/lib/systemd/system/NetworkManager.service /etc/systemd/system/dbus-org.freedesktop.NetworkManager.service
ln -sf /usr/lib/systemd/system/NetworkManager.service /etc/systemd/system/multi-user.target.wants/NetworkManager.service
ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
mkdir /etc/systemd/system/network-online.target.wants
ln -sf /usr/lib/systemd/system/NetworkManager-wait-online.service /etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service

echo_sleep "Setup fstrim..."
mkdir /etc/systemd/system/timers.target.wants
ln -sf /usr/lib/systemd/system/fstrim.timer /etc/systemd/system/timers.target.wants/fstrim.timer

echo_sleep "Setup tlp..."
ln -sf /usr/lib/systemd/system/tlp.service /etc/systemd/system/multi-user.target.wants/tlp.service
mkdir /etc/systemd/system/sleep.target.wants
ln -sf /usr/lib/systemd/system/tlp-sleep.service /etc/systemd/system/sleep.target.wants/tlp-sleep.service

echo_sleep "Disable pc speaker..."
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

echo_sleep "Limit systemd journald log size"
sed -i 's/#SystemMaxUse=/SystemMaxUse=50M/' /etc/systemd/journald.conf

echo_sleep "Setup data partition..."
mkdir /mnt/PODACI
chown vuk:wheel /mnt/PODACI
cat fstab >> /etc/fstab

chown -R vuk:wheel /opt/arch_install
cd /opt/arch_install

echo_sleep "Install yay..."
sed -i 's/#Color/Color/' /etc/pacman.conf
wget "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay" -O PKGBUILD
sudo -u vuk sh -c "yes | makepkg -si"

echo_sleep "Install AUR packages..."
sudo -u vuk sh -c "yes | yay -S --nodiffmenu --nocleanmenu --noprovides \$(cat packages_aur)"
ln -sf ../conf.avail/75-emojione.conf /etc/fonts/conf.d/75-emojione.conf

cd /opt
rm -rf /opt/arch_install

echo_sleep "Clean pacman/yay cache..."
rm -rf /var/cache/pacman/pkg/*
rm -rf /home/vuk/.cache/yay/*

echo_sleep "Setup oh-my-zsh for user..."
cd /home/vuk
sudo -u vuk sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

echo_sleep "Fetch configs for user..."
sudo -u vuk git init
sudo -u vuk git remote add origin https://github.com/wooque/configs
sudo -u vuk git fetch --all
sudo -u vuk git reset --hard origin/master
sudo -u vuk git branch --set-upstream-to=origin/master master
sudo -u vuk git remote set-url origin git@github.com:wooque/configs.git
