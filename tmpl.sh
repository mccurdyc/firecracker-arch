#!/bin/bash

# This script helps "render templates" of configuration files replacing variables

sed 's?'$1'?'"$2"'?' <&0
