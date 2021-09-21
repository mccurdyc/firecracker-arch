#! /usr/bin/env bash

set -x

source variables

function main() {
  local instance_number=$1
  local instance_rootfs="${DISK_DIR}/$(basename $IMAGE_ROOTFS).${instance_number}"
  local socket=$FIRECRACKER_SOCKET.$instance_number

  launch_vm $instance_number $socket
}

function firecracker_http_file() {
  sudo curl -v --unix-socket $1 \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -X $2 'http://localhost/'$3 --data-binary "@"$4
}

function create_tap() {
  local device=$1

  ip addr show $device >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    sudo ip tuntap add dev $device mode tap
    sudo ip link set dev $device up
  fi

  sudo ip link set $tap_main master $FIRECRACKER_BRIDGE
}

function launch_vm() {
  local instance_number=$1
  local socket=$2
  local log_file=$DATA_DIR/.fc.$instance_number.log
  local outfile=""

  # Start firecracker daemon
  (
    rm -f $socket
    touch $log_file
    sudo $FIRECRACKER \
      --api-sock $socket \
      --log-path $log_file \
      --level Error \
      --show-level \
      --show-log-origin &
    pid=$!
    echo $pid >$FIRECRACKER_PID_DIR/$pid
    echo "Started Firecracker with pid=$pid, logs: $log_file"
  )

  while [ ! -e $socket ]; do
    sleep 1s
  done

  # VM config
  outfile="${DATA_DIR}/instance-config.json.${instance_number}"
  cat conf/firecracker/instance-config.json |
    ./tmpl.sh __INSTANCE_VCPUS__ $VM_VCPUS |
    ./tmpl.sh __INSTANCE_RAM_MB__ $(($VM_RAM_GB * 1024)) \
      >$outfile
  firecracker_http_file $socket PUT 'machine-config' $outfile

  # Drives
  outfile="${DATA_DIR}/drives.json.${instance_number}"
  root_fs="${DISK_DIR}/"$(basename $IMAGE_ROOTFS).$instance_number
  cp $IMAGE_ROOTFS $root_fs
  cat conf/firecracker/drives.json |
    ./tmpl.sh __ROOT_FS__ $root_fs \
      >$outfile
  firecracker_http_file $socket PUT 'drives/rootfs' $outfile

  # Networking
  tap_main="fctap"$(printf "%02d" $(($instance_number - 1)))
  create_tap $tap_main

  outfile="${DATA_DIR}/network_interfaces.eth0.json.${instance_number}"
  mac_octet=$(printf '%02x' $(($instance_number + 1)))
  cat conf/firecracker/network_interfaces.eth0.json |
    ./tmpl.sh __MAC_OCTET__ $mac_octet |
    ./tmpl.sh __TAP_MAIN__ $tap_main \
      >$outfile
  firecracker_http_file $socket PUT 'network-interfaces/eth0' $outfile

  outfile="${DATA_DIR}/boot-source.json.${instance_number}"
  cat conf/firecracker/boot-source.json |
    ./tmpl.sh __KERNEL_IMAGE__ $KERNEL_IMAGE \
      >$outfile
  firecracker_http_file $socket PUT 'boot-source' $outfile

  # Start VM
  firecracker_http_file $socket PUT 'actions' conf/firecracker/instance-start.json
  [ $? -eq 0 ] && echo "Instance $instance_number started. Run 'nmap -sn 192.168.1.1/24' to find the instance's IP."
}

main $(($(find $FIRECRACKER_PID_DIR -type f | wc -l) + 1))
