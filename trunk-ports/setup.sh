#!/usr/bin/env bash
set -Eeuo pipefail

ip netns add router0

ip netns add switch0
ip link add router0 netns switch0 type veth peer switch0 netns router0

ip netns add host0
ip link add host0 netns switch0 type veth peer eth0 netns host0

ip netns add host1
ip link add host1 netns switch0 type veth peer eth0 netns host1

ip netns exec router0 bash -e <<NS
sysctl -w net.ipv4.ip_forward=1

ip link set switch0 up

ip link add link switch0 name switch0.10 type vlan id 10
ip link set switch0.10 up
ip addr add 192.168.10.1/24 dev switch0.10

ip link add link switch0 name switch0.20 type vlan id 20
ip link set switch0.20 up
ip addr add 192.168.20.1/24 dev switch0.20
NS

ip netns exec switch0 bash -e <<NS
ip link add bridge0 type bridge
ip link set bridge0 up

ip link set router0 up

ip link add link router0 name router0.10 type vlan id 10
ip link set router0.10 up
ip link set router0.10 master bridge0

ip link add link router0 name router0.20 type vlan id 20
ip link set router0.20 up
ip link set router0.20 master bridge0

ip link set host0 up
ip link set host0 master bridge0

ip link set host1 up
ip link set host1 master bridge0

bridge vlan add vid 10 dev host0 pvid untagged
bridge vlan add vid 20 dev host1 pvid untagged
NS

ip netns exec host0 bash -e <<NS
ip link set eth0 up
ip addr add 192.168.10.100/24 dev eth0
ip route add default via 192.168.10.1 dev eth0
NS

ip netns exec host1 bash -e <<NS
ip link set eth0 up
ip addr add 192.168.20.100/24 dev eth0
ip route add default via 192.168.20.1 dev eth0
NS
