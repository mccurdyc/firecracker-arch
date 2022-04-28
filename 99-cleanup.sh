#! /usr/bin/env bash

set -o nounset

source variables

instance_id=$1
tap_main_id="fctap-${instance_id}"

sudo ip link delete ${tap_main_id}

rm -rf data/${instance_id}.log
rm -rf ${FIRECRACKER_SOCKET}.${instance_id}
rm -rf data/boot-source.json.${instance_id}
rm -rf data/instance-config.json.${instance_id}
rm -rf data/drives.json.${instance_id}
rm -rf data/network_interfaces.eth0.json.${instance_id}
echo 'NOTE: disks/ need to be manually cleaned up as this is where state is stored.'
