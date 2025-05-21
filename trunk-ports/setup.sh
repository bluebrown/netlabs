#!/usr/bin/env bash
set -Eeuo pipefail

# suppose there is a router, with only a single physical link to a
# switch

ip netns add router0

ip netns add switch0
ip link add router0 netns switch0 type veth peer switch0 netns router0

# the switch is connected to some devices, but the devices are supposed
# to be in different subnets

ip netns add host0
ip link add host0 netns switch0 type veth peer eth0 netns host0

ip netns add host1
ip link add host1 netns switch0 type veth peer eth0 netns host1

# one solution for this is the use of VLANs through subinterfaces. each
# subnet is exposed via a subinterface of the router. This subinterface
# has a vlan id. frames traversing this link are expected to be tagged
# with the vlan id. This is done automatically by the type vlan
# interfaces.

ip netns exec router0 bash -ex <<NS
sysctl -w net.ipv4.ip_forward=1

ip link set switch0 up

ip link add link switch0 name switch0.10 type vlan id 10
ip link set switch0.10 up
ip addr add 192.168.10.1/24 dev switch0.10

ip link add link switch0 name switch0.20 type vlan id 20
ip link set switch0.20 up
ip addr add 192.168.20.1/24 dev switch0.20
NS

# the switch has vlan filtering enabled to ensure traffic segregation.
# Rhe router is connected to the switch via a trunk port, which is
# configured to allow traffic for both vlans. The router has two
# subinterfaces.

ip netns exec switch0 bash -ex <<NS
ip link add bridge0 type bridge
ip link set bridge0 up
ip link set dev bridge0 type bridge vlan_filtering 1

ip link set router0 up
ip link set router0 master bridge0
bridge vlan add vid 10 dev router0 tagged
bridge vlan add vid 20 dev router0 tagged

ip link set host0 up
ip link set host0 master bridge0
bridge vlan add vid 10 dev host0 pvid untagged

ip link set host1 up
ip link set host1 master bridge0
bridge vlan add vid 20 dev host1 pvid untagged
NS

# the hosts are connected to the switches untagged access ports, and
# have the routers vlan subinterfaces as default gateway. This way the
# router can route between the two subnets, if permitted by the firewall
# rules.

ip netns exec host0 bash -ex <<NS
ip link set eth0 up
ip addr add 192.168.10.100/24 dev eth0
ip route add default via 192.168.10.1 dev eth0
NS

ip netns exec host1 bash -ex <<NS
ip link set eth0 up
ip addr add 192.168.20.100/24 dev eth0
ip route add default via 192.168.20.1 dev eth0
NS
