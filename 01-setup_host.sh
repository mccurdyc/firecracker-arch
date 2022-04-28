#! /usr/bin/env bash

set -o nounset

source variables

# sudo ip link add name $FIRECRACKER_BRIDGE type bridge
# sudo ip addr add $VMS_NETWORK_PREFIX.2/24 dev $FIRECRACKER_BRIDGE
# sudo ip link set dev $FIRECRACKER_BRIDGE up
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
sudo iptables --table nat --append POSTROUTING --out-interface $EGRESS_IFACE -j MASQUERADE
sudo iptables --insert FORWARD --in-interface $FIRECRACKER_BRIDGE -j ACCEPT

mkdir -p $FIRECRACKER_PID_DIR
mkdir -p $DATA_DIR
mkdir -p $DISK_DIR
