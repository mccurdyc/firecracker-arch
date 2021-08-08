#!/bin/bash

tap_dev_suffix=$(hexdump -n 2 -e '4/4 "%04X" 1 "\n"' /dev/random | tr '[:upper:]' '[:lower:]' | awk '{$1=$1};1')
tmp_config_file="/tmp/firecracker-${tap_dev_suffix}"

function main() {
  create_tap_interface
  create_configuration
  start_vm
  delete_tap_interface
  cleanup
}

function create_tap_interface() {
  ip tuntap add tap${tap_dev_suffix} mode tap
  ip link set tap${tap_dev_suffix} up
  ip link set dev tap${tap_dev_suffix} master br0
}

function create_configuration() {
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
      "guest_mac": "AA:FC:00:00:00:02",
      "host_dev_name": "tap${tap_dev_suffix}"
    }
  ]
}
EOF
}

function start_vm() {
  firecracker \
    --no-api \
    --config-file $tmp_config_file
}


function delete_tap_interface() {
  ip link set tap${tap_dev_suffix} down
  ip link set dev tap${tap_dev_suffix} nomaster
  ip tuntap del tap${tap_dev_suffix} mode tap
}

function cleanup() {
  rm $tmp_config_file
}

main
