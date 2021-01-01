Partion disk:

`fdisk /dev/sda`

Usefull commans: `n` new partition, `a` set bootable flag, `w` write changes to disk

Bootstrap inital env (`/dev/sda1` is default):

`./bootstrap.sh [/dev/sda1]`

When in chroot run full install:

`/root/install.sh`

