#! /usr/bin/env bash

set -o nounset

source variables

for i in $(find $FIRECRACKER_PID_DIR -type f); do
  kill $(cat $i) 2>/dev/null
done
