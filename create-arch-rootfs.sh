#!/usr/bin/env bash
# https://blog.herecura.eu/blog/2020-05-21-toying-around-with-firecracker/
set -eu -o pipefail

NAME=$1

: ${NAME:="arch-rootfs"}

[[ -e $NAME.ext4 ]] && rm $NAME.ext4

truncate -s 2G $NAME.ext4
sudo mkfs.ext4 $NAME.ext4

# cleanup first
sudo umount /mnt/arch-root
sudo rmdir /mnt/arch-root

sudo mkdir -p /mnt/arch-root
sudo mount "$(pwd)"/$NAME.ext4 /mnt/arch-root
sudo pacstrap /mnt/arch-root base \
  base-devel \
  openssh \
  sudo

sudo mkdir -p /mnt/arch-root/home/mccurdyc/
sudo cp -r $(pwd)/etc /mnt/arch-root

sudo rm /mnt/arch-root/etc/systemd/system/getty.target.wants/*
sudo rm /mnt/arch-root/etc/systemd/system/multi-user.target.wants/*

sudo ln -s /dev/null /mnt/arch-root/etc/systemd/system/systemd-random-seed.service
sudo ln -s /dev/null /mnt/arch-root/etc/systemd/system/cryptsetup.target

arch-chroot /mnt/arch-root systemctl enable --now systemd-networkd.service
arch-chroot /mnt/arch-root systemctl enable --now sshd.service

sudo umount /mnt/arch-root
sudo rmdir /mnt/arch-root
