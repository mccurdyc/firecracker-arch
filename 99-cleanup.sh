#!/bin/bash

source variables

number_vms=$(find $FIRECRACKER_PID_DIR -type f | wc -l)

for i in $(seq 0 $(($number_vms - 1))); do
  tap_main_id="fctap$(printf "%02d" $i)"

  sudo ip link delete ${tap_main_id}
done

# sudo ip link delete $FIRECRACKER_BRIDGE
rm -rf data/*
rm -rf disks/*
rm -rf data/.fc.*.log
rm -rf .firecracker/*
