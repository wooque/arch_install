#!/bin/bash
echo_sleep () { echo "$1"; sleep 1; }

PART=${1:-"/dev/sda1"}
MOUNT=/mnt

echo_sleep "Set ntp..."
timedatectl set-ntp true

echo_sleep "Format $PART..."
mkfs.ext4 -F "$PART"

echo_sleep "Mount $PART..."
mount "$PART" "$MOUNT"

echo_sleep "Pacstrap..."
pacstrap "$MOUNT" base base-devel linux linux-firmware 

echo_sleep "Gen fstab..."
genfstab -U "$MOUNT" >> "$MOUNT/etc/fstab"
sed -i 's/relatime/noatime/' "$MOUNT/etc/fstab"

echo_sleep "Copy install script to /root..."
cp install.sh "$MOUNT/root"

echo_sleep "Chroot..."
arch-chroot "$MOUNT" /root/install.sh

echo_sleep "Reboot..."
reboot
