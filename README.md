# Manual

`fdisk /dev/sda`
`./init.sh /dev/sda1`

when in chroot:
`/opt/arch_install/install.sh user /dev/sda`

# Possible problems

- Intel tear-free fix, fix it by removing `/etc/X11/xorg.conf.d/20-intel.conf`

- Data partition with label PODACI expected, remove it from `/etc/fstab`

