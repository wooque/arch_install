#!/bin/bash
ESP_PART="/dev/nvme0n1p1"
INSTALL_PART="/dev/nvme0n1p2"
MOUNT=/mnt

NEWUSER="vuk"
PASS="pass"
NEWUSER_GROUPS="docker"
TIMEZONE="Europe/Belgrade"
HOSTNAME="pc"
LOCALE="en_US.UTF-8"

PACKAGES_BOOT="amd-ucode"
PACKAGES_HW="libva-mesa-driver amdvlk"
PACKAGES_BASE="nano man-db bash-completion cronie tlp ethtool powertop wireless-regdb git openssh wireplumber pipewire-pulse pipewire-jack iwd fuse2 efibootmgr"
PACKAGES_DE="phonon-qt5-gstreamer plasma-desktop plasma-wayland-session plasma-nm plasma-pa kscreen powerdevil bluedevil khotkeys kinfocenter kde-gtk-config breeze-gtk xdg-desktop-portal xdg-desktop-portal-kde konsole dolphin kdialog plasma-workspace-wallpapers discover packagekit-qt5 kwalletmanager libappindicator-gtk3"
PACKAGES_FONTS="noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-liberation ttf-dejavu"
PACKAGES_APPS="kwrite mate-calc spectacle ark gwenview okular juk transmission-qt kdiff3 mpv gimp libreoffice-fresh firefox"
PACKAGES_UTILS="z htop radeontop ncdu rsync imagemagick yt-dlp ranger neofetch"
PACKAGES_DEV="docker docker-compose tk typescript-language-server tokei"
PACKAGES_VM="qemu-desktop samba"
PACKAGES_AUR="brave-bin viber slack-desktop visual-studio-code-bin beekeeper-studio-appimage dropbox insomnia-bin asdf-vm "
PACKAGES="$PACKAGES_HW $PACKAGES_BASE $PACKAGES_FONTS $PACKAGES_DE $PACKAGES_APPS $PACKAGES_UTILS $PACKAGES_DEV $PACKAGES_VM"
SERVICES="NetworkManager bluetooth cronie tlp fstrim.timer docker.socket"

CRON="0 11,17,23 * * * bash -ic backup"
FSTAB=("LABEL=PODACI /mnt/PODACI ext4 rw,noatime,x-gvfs-show 0 0")
DOTFILES_GITHUB="wooque/dotfiles"

echo_sleep () { echo "$1"; sleep 1; }
