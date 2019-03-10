## Manual

Partion disk:

`fdisk /dev/sda`

Bootstrap inital env on `/dev/sda1` (default):

`./init.sh [/dev/sda1]`

When in chroot run full install.
`vuk` is default username, `/dev/sda` is default location where GRUB should be installed:

`/opt/arch_install/install.sh [vuk] [/dev/sda]`

## Possible problems

- Intel tear-free fix, fix it by removing `/etc/X11/xorg.conf.d/20-intel.conf`

- Data partition with label `PODACI` expected, fix it by removing it from `/etc/fstab`

