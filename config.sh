#!/bin/bash
INSTALL_PART="/dev/sda1"
MOUNT=/mnt
BOOT_DISK="/dev/sda"
NEWUSER="vuk"
NEWUSER_GROUPS="docker"
TIMEZONE="/usr/share/zoneinfo/Europe/Belgrade"
HOSTNAME="battlestation"
LOCALE="en_US.UTF-8"
DE="gnome"
PACKAGES_BOOT="grub intel-ucode"
PACKAGES_BASE="nano man-db bash-completion cronie tlp crda networkmanager libva-intel-driver git"
if [[ "$DE" = "plasma" ]]; then
# noto-fonts-cjk for chinese/japanese characters, gnome is able to use ttf-droid
# install imagemagick explicitly, gnome is pulling it as dep
PACKAGES_DE="sddm sddm-kcm plasma-desktop kscreen plasma-nm plasma-pa pulseaudio-bluetooth powerdevil bluedevil khotkeys kinfocenter konsole dolphin plasma-workspace-wallpapers kde-gtk-config noto-fonts-cjk imagemagick"
elif [[ "$DE" = "gnome" ]]; then
PACKAGES_DE="gdm gnome-control-center gnome-terminal nautilus gnome-backgrounds gnome-keyring gnome-tweaks chrome-gnome-shell"
fi
PACKAGES_FONTS="ttf-liberation ttf-dejavu ttf-droid noto-fonts-emoji"
PACKAGES_APPS="chromium mpv gimp libreoffice"
if [[ "$DE" = "plasma" ]]; then
PACKAGES_APPS="kwrite kcalc spectacle ark gwenview okular juk transmission-qt kdiff3 $PACKAGES_APPS"
elif [[ "$DE" = "gnome" ]]; then
PACKAGES_APPS="gedit gnome-calculator gnome-screenshot file-roller eog evince rhythmbox transmission-gtk meld $PACKAGES_APPS"
fi
PACKAGES_UTILS="z htop ncdu rsync bluez-utils"
PACKAGES_DEV="docker-compose nodejs npm code tk"
PACKAGES_VM="qemu samba"
PACKAGES_AUR="dropbox viber insomnia-bin tableplus"
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
