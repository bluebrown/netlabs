#!/usr/bin/env bash
set -Eeuo pipefail

# this namespace has an interface into each subnet.
# it forwards packets between them
ip netns add router0
ip netns exec router0 sysctl -w net.ipv4.ip_forward=1

# two switches are connected to the router
for si in {0..1}; do
  switch="switch$si"
  subnet="192.168.$si"   # each switch has its own subnet
  gw_addr="$subnet.1/24" # its interface in the router ns is the default gww for subnet

  # the switch namespace has a bridge interface connecting
  # the downstream hosts to the router interface
  ip netns add "$switch"
  ip netns exec "$switch" ip link add bridge0 type bridge
  ip netns exec "$switch" ip link set bridge0 up

  # its veth pair, connected to the router, is added to the bridge.
  # it does not need an IP address, as it is a transparent layer 2 device
  ip netns exec "$switch" ip link add router0 type veth peer "$switch" netns router0
  ip netns exec "$switch" ip link set router0 up
  ip netns exec "$switch" ip link set router0 master bridge0

  ip netns exec router0 ip link set "$switch" up
  ip netns exec router0 ip addr add "$gw_addr" dev "$switch"

  # in each subnets are two hosts
  for hi in {0..1}; do
    host="host$((si << 1 | hi))"
    host_addr="$subnet.10$hi/24"

    ip netns add "$host"

    #  the hosts eth0 interface is a veth pair with one end in
    #  the host namespace and the other in the switch namespace
    ip netns exec "$host" ip link add eth0 type veth peer "$host" netns "$switch"
    ip netns exec "$host" ip link set eth0 up

    # the switch end of the veth pair is added to the bridge,
    # extending the router interfaces broadcast domain
    ip netns exec "$switch" ip link set "$host" master bridge0
    ip netns exec "$switch" ip link set "$host" up

    # the host needs a default route to reach the router. It also needs
    # an IP address on the subnet, so that the router can forward
    # packets to it. The router interface is the default gw
    ip netns exec "$host" ip addr add "$host_addr" dev eth0
    ip netns exec "$host" ip route add default via "$subnet.1" dev eth0
  done
done
