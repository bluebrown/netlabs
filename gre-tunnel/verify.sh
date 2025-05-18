#!/usr/bin/env bash
set -Eeuo pipefail

ip netns exec site1 ping -I eth0 -c 1 10.200.0.1
ip netns exec site2 ping -I eth0 -c 1 10.100.0.1

ip netns exec lan1 ping -W 1 -c 1 -I eth0 172.16.100.254
ip netns exec lan2 ping -W 1 -c 1 -I eth0 172.16.200.254

ip netns exec lan1 ping -W 1 -c 1 172.16.200.1
ip netns exec lan2 ping -W 1 -c 1 172.16.100.1
