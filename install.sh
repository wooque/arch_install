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

#echo_sleep "Create initial ramdisk..."
#mkinitcpio -p linux

echo "Enter password for root"
passwd

cd /opt/arch_install
echo_sleep "Install base packages..."
pacman --noconfirm -S $(cat packages/base)
echo_sleep "Install extra packages..."
pacman --noconfirm -S $(cat packages/extra)

echo_sleep "Install grub..."
pacman -S --noconfirm grub os-prober
grub-install /dev/sda

echo_sleep "Create grub.cfg..."
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="elevator=deadline"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo_sleep "Create user..."
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
groupadd autologin
useradd -g wheel -G autologin,docker,vboxusers -m vuk
echo "Enter password for vuk"
passwd vuk

echo_sleep "Setup lighdm..."
cp lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf
# enable this for autologin
#sed -i 's/#autologin-user=/autologin-user=vuk/' /etc/lightdm/lightdm.conf
ln -sf /usr/lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service

echo_sleep "Setup cron..."
cp crontab /var/spool/cron/vuk
cp root_crontab /var/spool/cron/root
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

echo_sleep "Setup data partition..."
mkdir /mnt/PODACI
chown vuk:wheel /mnt/PODACI
cat fstab >> /etc/fstab

echo_sleep "Install yaourt..."
cd /opt
mkdir build
chown vuk:wheel build
cd build

wget "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=package-query" -O PKGBUILD
sudo -u vuk makepkg -s
pacman -U --noconfirm $(find . -name "package-query*.pkg.tar.xz")

wget "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yaourt" -O PKGBUILD
sudo -u vuk makepkg -s
pacman -U --noconfirm $(find . -name "yaourt*.pkg.tar.xz")

cd /opt
rm -rf /opt/build

echo_sleep "Install AUR base packages..."
cd /opt/arch_install
sudo -u vuk yaourt -S --noconfirm $(cat packages/aur_base)
ln -sf ../conf.avail/75-emojione.conf /etc/fonts/conf.d/75-emojione.conf
sed -i 's/Exec=\/usr\/bin\/chromium %U/Exec=\/usr\/bin\/chromium %U --password-store=gnome/' /usr/share/applications/chromium.desktop

echo_sleep "Install AUR conflict packages..."
sudo -u vuk yaourt -S --noconfirm $(cat packages/aur_conflict)
yes | pacman -U $(find /tmp/yaourt-tmp-vuk -name "freetype2-ultimate5*.pkg.tar.xz")


echo_sleep "Install AUR extra packages..."
# for ncurses needed for VMWare player
sudo -u vuk gpg --recv-key 702353E0F7E48EDB
sudo -u vuk yaourt -S --noconfirm $(cat packages/aur_extra)
cd /opt
rm -rf /opt/arch_install

echo_sleep "Remove unneeded packages..."
pacman -Rs $(pacman -Qtdq)

echo_sleep "Clean pacman cache..."
rm -rf /var/cache/pacman/pkg/*

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
