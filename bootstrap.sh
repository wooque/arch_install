#!/bin/bash
echo_sleep () { echo "$1"; sleep 1; }

PART=/dev/sda1

echo_sleep "Set ntp..."
timedatectl set-ntp true

echo_sleep "Format $PART..."
mkfs.ext4 -F "$PART"

echo_sleep "Mount $PART..."
mount "$PART" /mnt

echo_sleep "Pacstrap..."
pacstrap /mnt base base-devel linux linux-firmware nano

echo_sleep "Gen fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/relatime/noatime/' /mnt/etc/fstab

echo_sleep "Copy install script to /root..."
cp install.sh /mnt/root

echo_sleep "Chroot..."
arch-chroot /mnt
