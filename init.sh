#!/bin/bash

echo_sleep () { 
    echo $1 
    sleep 1 
}

echo_sleep "Set ntp..."
timedatectl set-ntp true

echo_sleep "Format sda1..."
mkfs.ext4 /dev/sda1

echo_sleep "Mount sda1..."
mount /dev/sda1 /mnt

echo_sleep "Pacstrap..."
pacstrap /mnt base base-devel

echo_sleep "Gen fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/rw,relatime/rw,noatime/' /mnt/etc/fstab

echo_sleep "Copy scripts to /opt..."
cp -r arch_install /mnt/opt/arch_install

echo_sleep "Chroot..."
arch-chroot /mnt
