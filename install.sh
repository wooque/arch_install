#!/bin/bash
. ./config.sh

echo_sleep "Set ntp..."
timedatectl set-ntp true

echo_sleep "Format $INSTALL_PART..."
mkfs.ext4 -F "$INSTALL_PART"

echo_sleep "Mount $INSTALL_PART..."
mkdir -p "$MOUNT"
mount "$INSTALL_PART" "$MOUNT"

echo_sleep "Mount $ESP_PART..."
mkdir -p "$MOUNT/boot"
mount "$ESP_PART" "$MOUNT/boot"

echo_sleep "Pacstrap..."
pacstrap "$MOUNT" base base-devel linux linux-firmware

echo_sleep "Gen fstab..."
genfstab -U "$MOUNT" >> "$MOUNT/etc/fstab"
sed -i 's/relatime/noatime/g' "$MOUNT/etc/fstab"

echo_sleep "Copy install script to /root..."
cp config.sh chroot.sh dconf.conf "$MOUNT/root"

echo_sleep "Chroot and install..."
arch-chroot "$MOUNT" /root/chroot.sh

echo_sleep "Unmount $INSTALL_PART..."
umount "$MOUNT"
