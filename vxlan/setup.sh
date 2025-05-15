#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(dirname "$(readlink -f "$0")")
bash "$script_dir/../routing-and-switching/setup.sh"

# bridge needs ip for the vxlan peers and know the default gw
# create vxlan interface with vni 10 using the bridges ips as endpoints,
# without specying the device name, instead enlave it to the bridge
ip netns exec switch0 bash -e <<NS
ip addr add 192.168.0.254/24 dev bridge0
ip route add default via 192.168.0.1 dev bridge0
ip link add vxlan0 type vxlan id 10 local 192.168.0.254 remote 192.168.1.254 dstport 4789
ip link set dev vxlan0 master bridge0
ip link set vxlan0 up
NS

# change the ip of the host to a new subnets that will only be reachable
# through the vxlan interface. this works because they the vxlan tunnel
# extends the broadcast domain. however, note that there is no
# seperation between the 2 different networks on the bridge. packets for
# addresses in one network will be sent to the other network. perhaps
# vlan tagging could be used to separate the networks
ip netns exec host1 bash -e <<NS
ip addr flush eth0
ip addr add 172.16.0.100/24 dev eth0
NS

# to the same as the other side
ip netns exec switch1 bash -e <<NS
ip addr add 192.168.1.254/24 dev bridge0
ip route add default via 192.168.1.1 dev bridge0
ip link add vxlan0 type vxlan id 10 local 192.168.1.254 remote 192.168.0.254 dstport 4789
ip link set dev vxlan0 master bridge0
ip link set vxlan0 up
NS

ip netns exec host3 bash -e <<NS
ip addr flush eth0
ip addr add 172.16.0.101/24 dev eth0
NS
