#!/usr/bin/env bash
# https://blog.herecura.eu/blog/2020-05-21-toying-around-with-firecracker/
# set -eu -o pipefail

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
# mkdir -p /mnt/arch-root/home/mccurdyc/.ssh
# mkdir -p /mnt/arch-root/home/mccurdyc/.tools
# mkdir -p /mnt/arch-root/home/mccurdyc/.cache/yay
#
sudo cp -r $(pwd)/etc /mnt/arch-root
#
# cp /home/mccurdyc/.ssh/id_ed25519.pub /mnt/arch-root/home/mccurdyc/.ssh
# cp /home/mccurdyc/.ssh/id_ed25519 /mnt/arch-root/home/mccurdyc/.ssh
# cp /home/mccurdyc/.ssh/config /mnt/arch-root/home/mccurdyc/.ssh
#
# cp -r /home/mccurdyc/dotfiles /mnt/arch-root/home/mccurdyc/dotfiles
# cp -r /opt/yay /mnt/arch-root/home/mccurdyc/.tools/yay
sudo hostnamectl hostname fc-arch

sudo rm /mnt/arch-root/etc/systemd/system/getty.target.wants/*
sudo rm /mnt/arch-root/etc/systemd/system/multi-user.target.wants/*

sudo ln -s /dev/null /mnt/arch-root/etc/systemd/system/systemd-random-seed.service
sudo ln -s /dev/null /mnt/arch-root/etc/systemd/system/cryptsetup.target

# arch-chroot /mnt/arch-root locale-gen en_US
# arch-chroot /mnt/arch-root chmod 0400 /etc/shadow /etc/gshadow
# arch-chroot /mnt/arch-root chown -R mccurdyc /home/mccurdyc
arch-chroot /mnt/arch-root systemctl enable --now systemd-networkd.service
arch-chroot /mnt/arch-root systemctl enable --now sshd.service
# arch-chroot /mnt/arch-root bash -c 'cd /home/mccurdyc/.tools/yay; runuser -u mccurdyc -- makepkg -si --noconfirm' # can't run as root
# arch-chroot /mnt/arch-root bash -c 'cd /home/mccurdyc/dotfiles; runuser -u mccurdyc -- make run'
# sudo arch-chroot /mnt/arch-root passwd -d root

# sudo umount /mnt/arch-root
# sudo rmdir /mnt/arch-root
