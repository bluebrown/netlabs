#!/usr/bin/env bash
set -Eeuo pipefail

ip tuntap add dev tap0 mode tap
ip link set dev tap0 up
ip addr add 192.168.0.10/24 dev tap0
