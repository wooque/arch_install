#!/bin/bash
INSTALL_PART="/dev/sda1"
MOUNT=/mnt
BOOT_DISK="/dev/sda"
NEWUSER="vuk"
PASS="pass"
NEWUSER_GROUPS="docker"
TIMEZONE="/usr/share/zoneinfo/Europe/Belgrade"
HOSTNAME="battlestation"
LOCALE="en_US.UTF-8"
DE="gnome"
PACKAGES_BOOT="grub intel-ucode"
PACKAGES_BASE="nano man-db bash-completion cronie tlp crda libva-intel-driver git"
if [[ "$DE" = "plasma" ]]; then
# install imagemagick explicitly, gnome is pulling it as dep
PACKAGES_DE="sddm-kcm plasma-desktop kscreen plasma-nm plasma-pa pulseaudio-bluetooth powerdevil bluedevil khotkeys kinfocenter kde-gtk-config konsole dolphin kdialog plasma-workspace-wallpapers imagemagick"
elif [[ "$DE" = "gnome" ]]; then
PACKAGES_DE="gdm gnome-control-center networkmanager gnome-terminal nautilus gnome-backgrounds gnome-keyring gnome-tweaks chrome-gnome-shell gnome-shell-extension-appindicator"
fi
PACKAGES_FONTS="noto-fonts-emoji"
if [[ "$DE" = "plasma" ]]; then
# noto-fonts is dependency of plasma-desktop, but install it explicitly so it's used as ttf-font provider
PACKAGES_FONTS="noto-fonts noto-fonts-cjk $PACKAGES_FONTS"
FONT_SANS="Noto Sans"
FONT_SERIF="Noto Serif"
FONT_MONOSPACE="Hack"
elif [[ "$DE" = "gnome" ]]; then
PACKAGES_FONTS="ttf-ubuntu-font-family ttf-dejavu ttf-droid $PACKAGES_FONTS"
FONT_SANS="Liberation Sans"
FONT_SERIF="Liberation Serif"
FONT_MONOSPACE="Ubuntu Mono"
fi
PACKAGES_APPS="chromium mpv gimp libreoffice-fresh"
if [[ "$DE" = "plasma" ]]; then
PACKAGES_APPS="kwrite kcalc spectacle ark gwenview okular juk transmission-qt kdiff3 $PACKAGES_APPS"
elif [[ "$DE" = "gnome" ]]; then
PACKAGES_APPS="gedit gnome-calculator gnome-screenshot file-roller eog evince rhythmbox transmission-gtk meld $PACKAGES_APPS"
fi
PACKAGES_UTILS="z htop ncdu rsync bluez-utils"
PACKAGES_DEV="docker-compose code tk"
PACKAGES_VM="qemu samba"
PACKAGES_AUR="gnome-shell-extension-dash-to-dock dropbox viber insomnia-bin tableplus asdf-vm"
SERVICES="NetworkManager bluetooth cronie tlp fstrim.timer docker.socket"
if [[ "$DE" = "plasma" ]]; then
SERVICES="sddm $SERVICES"
elif [[ "$DE" = "gnome" ]]; then
SERVICES="gdm $SERVICES"
fi
CRON="0 11,17,23 * * * bash -ic backup"
FSTAB=("LABEL=PODACI /mnt/PODACI ext4 noatime,x-gvfs-show 0 0")
DOTFILES_GITHUB="wooque/dotfiles"

echo_sleep () { echo "$1"; sleep 1; }
