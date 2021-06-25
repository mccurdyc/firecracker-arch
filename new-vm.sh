#!/bin/bash

N=$1
# ip tuntap add tap${N} mode tap
# ip link set tap${N} up
# ip link set dev tap${N} master br0

tmp_config_file=$(mktemp /tmp/firecracker-XXXXX)
cat <<EOF > $tmp_config_file
{
  "boot-source": {
    "kernel_image_path": "/home/mccurdyc/.firecracker/vmlinux",
    "boot_args": "console=ttyS0 reboot=k panic=1 pci=off"
  },
  "drives": [
    {
      "drive_id": "rootfs",
      "path_on_host": "/home/mccurdyc/.firecracker/arch-rootfs.ext4",
      "is_root_device": true,
      "is_read_only": false
    }
  ],
  "machine-config": {
    "vcpu_count": 2,
    "mem_size_mib": 2048,
    "ht_enabled": false
  },
  "network-interfaces": [
    {
      "iface_id": "eth0",
      "guest_mac": "AA:FC:00:00:00:01",
      "host_dev_name": "tap$N"
    }
  ]
}
EOF

firecracker \
  --no-api \
  --config-file $tmp_config_file
