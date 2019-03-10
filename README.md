# Manual

Partion disk:

`fdisk /dev/sda`

Bootstrap inital env on /dev/sda1:

`./init.sh /dev/sda1`

When in chroot run full install (user is username, /dev/sda is location where GRUB should be installed):

`/opt/arch_install/install.sh user /dev/sda`

# Possible problems

- Intel tear-free fix, fix it by removing `/etc/X11/xorg.conf.d/20-intel.conf`

- Data partition with label PODACI expected, fix it by removing it from `/etc/fstab`

