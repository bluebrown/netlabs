#!/usr/bin/env bash
set -Eeuo pipefail

# note, no explicit route is needed on the router. Linux automatically
# adds a route for each interface, when assigning an address to it.
# In this case the routes are:
# 192.168.0.0/24 dev box0 proto kernel scope link src 192.168.0.1
# 192.168.1.0/24 dev box1 proto kernel scope link src 192.168.1.1

# the router is a namespace with ipv4 forwarding enabled
ip netns add router0
ip netns exec router0 sysctl -w net.ipv4.ip_forward=1

for n in 0 1; do
  # for each box there is a namespace with a veth pair,
  # one end in the router namespace and the other in the box namespace
  ip netns add "box$n"
  ip link add "box$n" netns router0 type veth peer router0 netns "box$n"
  ip netns exec "box$n" ip link set router0 up
  ip netns exec router0 ip link set bo"x$n" up

  # each interace on the router represents a physical interface into a
  # different network. Each device in the network gets the ip of this
  # interface as default route, aka the gateway. For this to work, the
  # device itself must also have an address. The adress is used by the
  # router to lookup the mac address of the device. Additionally, linux
  # requires that the interface has an address in the same subnet
  ip netns exec router0 ip addr add "192.168.$n.1/24" dev "box$n"
  ip netns exec "box$n" ip addr add "192.168.$n.254/24" dev router0
  ip netns exec "box$n" ip route add default via "192.168.$n.1" dev router0
done
