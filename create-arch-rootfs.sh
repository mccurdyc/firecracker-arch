#!/usr/bin/env bash
# https://blog.herecura.eu/blog/2020-05-21-toying-around-with-firecracker/

set -o nounset

source variables

NAME=$1

: ${NAME:="arch-rootfs"}

[[ -e $NAME.ext4 ]] && rm $NAME.ext4

truncate -s ${IMAGE_SIZE} $NAME.ext4
sudo mkfs.ext4 $NAME.ext4

sudo mkdir -p /mnt/arch-root
sudo mount "$(pwd)/$NAME.ext4" /mnt/arch-root
sudo pacstrap /mnt/arch-root base \
  base-devel \
  openssh \
  mosh \
  sudo \
  vim \
  git \
  keychain \
  tailscale \
  expect

# Necessary to get attached to bridge and get SSH access.
sudo cp -r "$(pwd)/etc" /mnt/arch-root

sudo rm /mnt/arch-root/etc/systemd/system/getty.target.wants/*
sudo rm /mnt/arch-root/etc/systemd/system/multi-user.target.wants/*

sudo ln -s /dev/null /mnt/arch-root/etc/systemd/system/systemd-random-seed.service
sudo ln -s /dev/null /mnt/arch-root/etc/systemd/system/cryptsetup.target

# These fail, but that's okay, we just need the symlinks created.
sudo arch-chroot /mnt/arch-root systemctl enable --now systemd-networkd.service
sudo arch-chroot /mnt/arch-root systemctl enable --now sshd.service
sudo arch-chroot /mnt/arch-root systemctl enable --now tailscaled.service

sudo arch-chroot /mnt/arch-root useradd -m -G wheel -s /bin/bash foo

sudo umount /mnt/arch-root
mv $NAME.ext4 $IMAGE_DIR
