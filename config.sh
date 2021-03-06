#!/bin/bash
ESP_PART="/dev/nvme0n1p1"
INSTALL_PART="/dev/nvme0n1p2"
MOUNT=/mnt

NEWUSER="vuk"
PASS="pass"
NEWUSER_GROUPS="docker"
TIMEZONE="Europe/Belgrade"
HOSTNAME="battlestation"
LOCALE="en_US.UTF-8"

PACKAGES_BOOT="amd-ucode"
PACKAGES_BASE="nano man-db bash-completion cronie tlp crda libva-mesa-driver git"
PACKAGES_DE="gdm gnome-control-center networkmanager gnome-terminal nautilus gnome-backgrounds gnome-keyring gnome-tweaks chrome-gnome-shell gnome-shell-extension-appindicator"
PACKAGES_FONTS="noto-fonts-emoji ttf-liberation ttf-ubuntu-font-family ttf-dejavu ttf-droid"
PACKAGES_APPS="gedit gnome-calculator file-roller eog evince rhythmbox transmission-gtk chromium mpv gimp libreoffice-fresh"
PACKAGES_UTILS="z htop ncdu rsync bluez-utils"
PACKAGES_DEV="docker-compose code tk"
PACKAGES_VM="qemu samba"
PACKAGES_AUR="dropbox viber insomnia-bin tableplus asdf-vm"
PACKAGES="$PACKAGES_BASE $PACKAGES_DE $PACKAGES_FONTS $PACKAGES_APPS $PACKAGES_UTILS $PACKAGES_DEV $PACKAGES_VM"
SERVICES="gdm NetworkManager bluetooth cronie tlp fstrim.timer docker.socket"

CRON="0 11,17,23 * * * bash -ic backup"
FSTAB=("LABEL=PODACI /mnt/PODACI ext4 rw,noatime,x-gvfs-show 0 2")
FONT_SANS="Liberation Sans"
FONT_SERIF="Liberation Serif"
FONT_MONOSPACE="Ubuntu Mono"
DOTFILES_GITHUB="wooque/dotfiles"

echo_sleep () { echo "$1"; sleep 1; }
