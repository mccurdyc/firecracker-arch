#! /usr/bin/env bash

set -o nounset

# This script helps "render templates" of configuration files replacing variables

sed 's?'$1'?'"$2"'?' <&0
