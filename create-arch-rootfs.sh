#!/usr/bin/env bash
# https://blog.herecura.eu/blog/2020-05-21-toying-around-with-firecracker/
# set -eu -o pipefail

NAME=$1

: ${NAME:="arch-rootfs"}

[[ -e $NAME.ext4 ]] && rm $NAME.ext4

truncate -s 10G $NAME.ext4
mkfs.ext4 $NAME.ext4

# cleanup first
umount /mnt/arch-root
rmdir /mnt/arch-root

mkdir -p /mnt/arch-root
mount "$(pwd)"/$NAME.ext4 /mnt/arch-root
pacstrap /mnt/arch-root base \
  base-devel \
  git \
  vim \
  dhcpcd \
  openssh \
  go \
  tmux \
  sudo

mkdir -p /mnt/arch-root/home/mccurdyc/
mkdir -p /mnt/arch-root/home/mccurdyc/.ssh
mkdir -p /mnt/arch-root/home/mccurdyc/.tools
mkdir -p /mnt/arch-root/home/mccurdyc/.cache/yay

cp -r $(pwd)/etc /mnt/arch-root
cat <<EOF > /mnt/arch-root/usr/local/bin/set_unique_hostname.sh
#! /usr/bin/env bash

hostnamectl set-hostname firecracker-arch-$(hexdump -n 2 -e '4/4 "%04X" 1 "\n"' /dev/random | tr '[:upper:]' '[:lower:]')
EOF

chmod +x /mnt/arch-root/usr/local/bin/set_unique_hostname.sh

cp /home/mccurdyc/.ssh/id_ed25519.pub /mnt/arch-root/home/mccurdyc/.ssh
cp /home/mccurdyc/.ssh/id_ed25519 /mnt/arch-root/home/mccurdyc/.ssh
cp /home/mccurdyc/.ssh/config /mnt/arch-root/home/mccurdyc/.ssh

cp -r /home/mccurdyc/dotfiles /mnt/arch-root/home/mccurdyc/dotfiles
cp -r /opt/yay /mnt/arch-root/home/mccurdyc/.tools/yay

rm /mnt/arch-root/etc/systemd/system/getty.target.wants/*
rm /mnt/arch-root/etc/systemd/system/multi-user.target.wants/*

ln -s /dev/null /mnt/arch-root/etc/systemd/system/systemd-random-seed.service
ln -s /dev/null /mnt/arch-root/etc/systemd/system/cryptsetup.target

arch-chroot /mnt/arch-root locale-gen en_US
arch-chroot /mnt/arch-root chmod 0400 /etc/shadow /etc/gshadow
arch-chroot /mnt/arch-root chown -R mccurdyc: /home/mccurdyc
arch-chroot /mnt/arch-root systemctl enable --now systemd-networkd.service
arch-chroot /mnt/arch-root systemctl enable --now set_unique_hostname.service
arch-chroot /mnt/arch-root systemctl enable --now sshd.service
arch-chroot /mnt/arch-root systemctl enable --now tailscaled.service
arch-chroot /mnt/arch-root bash -c 'cd /home/mccurdyc/.tools/yay; runuser -u mccurdyc -- makepkg -si --noconfirm' # can't run as root
arch-chroot /mnt/arch-root bash -c 'cd /home/mccurdyc/dotfiles; runuser -u mccurdyc -- make run'

umount /mnt/arch-root
rmdir /mnt/arch-root
