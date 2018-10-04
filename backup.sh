#!/bin/bash

rsync -azP -e "ssh -p 21299" --exclude='*.iso' --exclude='*.vdi' --exclude='*.vmdk' /mnt/PODACI root@51.15.75.156:/root/backup --delete 
