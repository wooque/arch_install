#!/bin/bash
. /root/config.sh

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
echo -e "$PASS\n$PASS" | passwd

echo_sleep "Create user..."
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
useradd -g wheel -m $NEWUSER
echo "Enter password for $NEWUSER"
echo -e "$PASS\n$PASS" | passwd $NEWUSER

echo_sleep "Install bootloader..."
pacman -S --noconfirm $PACKAGES_BOOT
grub-install $BOOT_DISK
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo_sleep "Install packages..."
pacman --noconfirm -S $PACKAGES

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
    <prefer><family>$FONT_SERIF</family></prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer><family>$FONT_SANS</family></prefer>
  </alias>
  <alias>
    <family>sans</family>
    <prefer><family>$FONT_SANS</family></prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer><family>$FONT_MONOSPACE</family></prefer>
  </alias>
  <alias binding="same">
    <family>Helvetica</family>
    <prefer>
      <family>Liberation Sans</family>
    </prefer>
  </alias>
</fontconfig>
EOF

echo_sleep "Setup mounts..."
for f in "${FSTAB[@]}"; do
  dir=$(echo "$f" | cut -d ' ' -f2)
  [[ -z "$dir" ]] && continue
  mkdir "$dir"
  chown $NEWUSER:wheel "$dir"
  echo "$f" >> /etc/fstab
done

echo_sleep "Fetch dotfiles..."
cd "/home/$NEWUSER"
sudo -u $NEWUSER git init
sudo -u $NEWUSER git remote add origin "https://github.com/$DOTFILES_GITHUB"
sudo -u $NEWUSER git fetch --set-upstream origin master
sudo -u $NEWUSER git reset --hard origin/master
sudo -u $NEWUSER git remote set-url origin "git@github.com:$DOTFILES_GITHUB.git"

echo_sleep "Load dconf..."
sudo -u $NEWUSER dconf load / < /root/dconf.conf

mkdir /tmp/aur
chown $NEWUSER:wheel /tmp/aur
cd /tmp/aur

echo_sleep "Install yay..."
sed -i 's/#Color/Color/' /etc/pacman.conf
curl "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay-bin" -o PKGBUILD
sudo -u $NEWUSER makepkg -s
pacman --noconfirm -U "$(ls yay-bin*)"

echo_sleep "Install AUR packages..."
sudo -u $NEWUSER sh -c "yes | yay -S --nodiffmenu --nocleanmenu --noprovides --removemake $PACKAGES_AUR"

rm -f /root/config.sh /root/chroot.sh /root/dconf.conf

echo_sleep "Clean pacman/yay cache..."
yes | yay -Scc

exit
