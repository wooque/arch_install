#!/bin/bash
. /root/config.sh

echo_sleep "Setup time..."
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
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
EOF

echo_sleep "Create user..."
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
useradd -g wheel -m $NEWUSER
echo "Enter password for $NEWUSER"
echo -e "$PASS\n$PASS" | passwd $NEWUSER

echo_sleep "Install bootloader..."
pacman -S --noconfirm $PACKAGES_BOOT
bootctl install
INSTALL_UUID=$(blkid -s UUID -o value "$INSTALL_PART")
echo "timeout 0" >> /boot/loader/loader.conf
cat >> /boot/loader/entries/arch.conf << EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root="UUID=$INSTALL_UUID" rw quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log_level=3 mitigations=off amd_iommu=off
EOF

echo_sleep "Disable pcspkr..."
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

echo_sleep "Install packages..."
pacman -S --noconfirm $PACKAGES

echo_sleep "Setup user groups..."
usermod -aG "$NEWUSER_GROUPS" "$NEWUSER"

echo_sleep "Enable services..."
systemctl enable $SERVICES

echo_sleep "Setup cron..."
echo "$CRON" >> "/var/spool/cron/$NEWUSER"

echo_sleep "Setup systemd tweaks..."
sed -i 's/#SystemMaxUse=/SystemMaxUse=10M/' /etc/systemd/journald.conf
sed -i 's/#Storage=external/Storage=none/' /etc/systemd/coredump.conf

echo_sleep "Setup autologin..."
mkdir  /etc/systemd/system/getty@tty1.service.d
cat >> /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
Type=simple
ExecStart=
ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin $NEWUSER --noclear %I \$TERM
EOF

echo_sleep "Disable Bluetooth hardware volume..."
mkdir -p /etc/wireplumber/bluetooth.lua.d
cp /usr/share/wireplumber/bluetooth.lua.d/50-bluez-config.lua /etc/wireplumber/bluetooth.lua.d
sed -i 's/\-\-\["bluez5.enable\-hw\-volume"\] = true/\["bluez5.enable\-hw\-volume"\] = false/' /etc/wireplumber/bluetooth.lua.d/50-bluez-config.lua

echo_sleep "Setup TLP..."
cat >> /etc/tlp.d/custom.conf << EOF
CPU_SCALING_GOVERNOR_ON_AC=schedutil
CPU_SCALING_GOVERNOR_ON_BAT=powersave
PLATFORM_PROFILE_ON_AC=performance
PLATFORM_PROFILE_ON_BAT=low-power
RADEON_DPM_PERF_LEVEL_ON_AC=auto
RADEON_DPM_PERF_LEVEL_ON_BAT=low
PCIE_ASPM_ON_AC=default
PCIE_ASPM_ON_BAT=powersupersave
EOF

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
  <alias binding="strong">
    <family>serif</family>
    <prefer>
    <family>Liberation Serif</family>
    <family>DejaVu Serif</family>
    <family>Noto Color Emoji</family>
    <family>Symbola</family>
    </prefer>
  </alias>
  <alias binding="strong">
    <family>sans-serif</family>
    <prefer>
    <family>Liberation Sans</family>
    <family>DejaVu Sans</family>
    <family>Noto Color Emoji</family>
    <family>Symbola</family>
    </prefer>
  </alias>
  <alias binding="strong">
    <family>sans</family>
    <prefer>
    <family>Liberation Sans</family>
    <family>DejaVu Sans</family>
    <family>Noto Color Emoji</family>
    <family>Symbola</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer><family>DejaVu Sans Mono</family></prefer>
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
yes | pacman -Scc
rm -rf /home/$NEWUSER/.cache/yay

exit
