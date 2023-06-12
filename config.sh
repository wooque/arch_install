#!/bin/bash
ESP_PART="/dev/nvme0n1p1"
INSTALL_PART="/dev/nvme0n1p5"
MOUNT=/mnt

NEWUSER="vuk"
PASS="pass"
NEWUSER_GROUPS="docker"
TIMEZONE="Europe/Belgrade"
HOSTNAME="pc"
LOCALE="en_US.UTF-8"

PACKAGES_BOOT="amd-ucode"
PACKAGES_BASE="nano man-db bash-completion cronie tlp ethtool wireless-regdb
git openssh wireplumber pipewire-pulse pipewire-jack efibootmgr bluez"
PACKAGES_DE="sway polkit foot swaybg waybar otf-font-awesome swayidle swaylock wofi
mako kanshi xdg-desktop-portal-wlr grim slurp xorg-xwayland brightnessctl thunar gvfs gvfs-mtp
tumbler ffmpegthumbnailer networkmanager pavucontrol bluez-utils playerctl"
PACKAGES_FONTS="noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-liberation ttf-dejavu"
PACKAGES_APPS="mousepad mate-calc xarchiver zip unzip ristretto webp-pixbuf-loader zathura
zathura-pdf-poppler cmus transmission-gtk meld mpv libva-mesa-driver gimp libreoffice-fresh firefox
nicotine+ signal-desktop"
PACKAGES_UTILS="htop radeontop powertop ncdu rsync imagemagick yt-dlp ranger neofetch
qemu-base qemu-ui-gtk qemu-audio-pa samba rclone"
PACKAGES_DEV="docker docker-compose tk nodejs npm yarn"
PACKAGES_AUR="viber visual-studio-code-bin beekeeper-studio-bin dropbox asdf-vm google-chrome"
PACKAGES="$PACKAGES_BASE $PACKAGES_FONTS $PACKAGES_DE $PACKAGES_APPS $PACKAGES_UTILS $PACKAGES_DEV"
SERVICES="NetworkManager bluetooth cronie tlp fstrim.timer docker.socket"

CRON="0 17,23 * * * bash -ic backup"
FSTAB=("LABEL=PODACI /mnt/PODACI ext4 rw,noatime,x-gvfs-show 0 1")
DOTFILES_GITHUB="wooque/dotfiles"

echo_sleep () { echo "$1"; sleep 1; }
