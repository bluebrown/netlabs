#!/usr/bin/env bash
set -Eeuo pipefail

ip link add bridge0 type bridge
ip link set bridge0 up

for n in {0..1}; do
  ip netns add "box$n"
  ip link add "veth$n" type veth peer eth0 netns "box$n"
  ip netns exec "box$n" ip addr add "192.168.1.$((100 + n))/24" dev eth0
  ip netns exec "box$n" ip link set eth0 up
  ip link set "veth$n" master bridge0
  ip link set "veth$n" up
done
