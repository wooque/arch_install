## Manual

Partion disk:

`fdisk /dev/sda`

Usefull commans: `n` new partition, `a` set bootable flag, `w` write changes to disk

Bootstrap inital env on `/dev/sda1` (default):

`./init.sh [/dev/sda1]`

When in chroot run full install.
`/dev/sda` is default location where GRUB should be installed, `vuk` is default username:

`/opt/arch_install/install.sh [/dev/sda vuk]`

## Possible problems

- Intel tear-free fix, fix it by removing `/etc/X11/xorg.conf.d/20-intel.conf`

- Data partition with label `PODACI` expected, fix it by removing it from `/etc/fstab`

