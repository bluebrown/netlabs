#!/usr/bin/env bash
set -Eeuo pipefail

# Preface

# NOTE
# 10.0.0.0/8 used for wan / public web (untrusted)
# 172.16.0.0/12 used for private networks of sites (lan1, lan2)
# 192.168.1.0/30  used for gre tunnel (overlay network)

# namespaces represent isolated network devices
ip netns add wan0
ip netns add site1
ip netns add site2
ip netns add lan1
ip netns add lan2

# Section 1

# wan0 is some uplink router, representing a wide area network (WAN) or the
# public internet

ip netns exec wan0 bash -e <<NS
sysctl -w net.ipv4.ip_forward=1

ip link add eth1 type veth peer name eth0 netns site1
ip link set eth1 up
ip addr add 10.100.0.254/16 dev eth1

ip link add eth2 type veth peer name eth0 netns site2
ip link set eth2 up
ip addr add 10.200.0.254/16 dev eth2
NS

# given two sites, site1 and site2, each connected to the WAN.
# traffic from site1 to site2 and vice versa is routed through the WAN.

ip netns exec site1 bash -e <<NS
ip link set eth0 up
ip addr add 10.100.0.1/16 dev eth0
ip route add default via 10.100.0.254 dev eth0
NS

ip netns exec site2 bash -e <<NS
ip link set eth0 up
ip addr add 10.200.0.1/16 dev eth0
ip route add default via 10.200.0.254 dev eth0
NS

# connectivity test 1

ip netns exec site1 ping -I eth0 -c 3 10.200.0.1
# PING 10.200.0.1 (10.200.0.1) from 10.100.0.1 eth0: 56(84) bytes of data.
# 3 packets transmitted, 3 received, 0% packet loss, time 2094ms

ip netns exec site2 ping -I eth0 -c 3 10.100.0.1
# PING 10.100.0.1 (10.100.0.1) from 10.200.0.1 eth0: 56(84) bytes of data.
# 3 packets transmitted, 3 received, 0% packet loss, time 2073ms

# Section 2

# each site has some private networks, in this case lan1 and lan2.
# the private network is used for internal communication between devices
# within the site, and not connected to the WAN.

ip netns exec site1 bash -e <<NS
ip link add eth1 type veth peer name eth0 netns lan1
ip link set eth1 up
ip addr add 172.16.100.254/24 dev eth1
NS

ip netns exec lan1 bash -e <<NS
ip link set eth0 up
ip addr add 172.16.100.1/24 dev eth0
NS

ip netns exec site2 bash -e <<NS
ip link add eth1 type veth peer name eth0 netns lan2
ip link set eth1 up
ip addr add 172.16.200.254/24 dev eth1
NS

ip netns exec lan2 bash -e <<NS
ip link set eth0 up
ip addr add 172.16.200.1/24 dev eth0
NS

# connectivity test 2

ip netns exec lan1 ping -W 1 -c 1 -I eth0 172.16.100.254
# PING 172.16.100.254 (172.16.100.254) from 172.16.100.1 eth0: 56(84) bytes of data.
# 1 packets transmitted, 1 received, 0% packet loss, time 0ms

ip netns exec lan2 ping -W 1 -c 1 -I eth0 172.16.200.254
# PING 172.16.200.254 (172.16.200.254) from 172.16.200.1 eth0: 56(84) bytes of data.
# 1 packets transmitted, 1 received, 0% packet loss, time 0ms

# Section 3

# suppose each site wants devices in their private network to be able to
# communicate with devices of the other site's private network. At the moment,
# the private networks are only known to each site, and not the the wan. So
# direct routing is not possible. Static routes could be added to the wan
# router, but that is not very realistc, because usually we are not in control
# of this router. Another solution could be network adress translation, where
# all device IPs are translated to the same public IP, known to the wan. This
# works only for outbound, unless port forwarding is configured.
#
# Another possible soltion for this is "tunneling". The idea is to take the
# packets with the private source/dest IPs, and wrap them in new packets with
# the wan IPs. So the packets are *encapuslated*. This way the new packet can
# be routed through the wan. On the other side, it can be decapsulated again,
# and the inner packet with the private IPs can be routed.

# each site creates a *gre* tunnel interface, using the (routable) wan IPs as
# *underlay network. Additionally, this device gets an IP in its *overlay
# network*, i.e. 192.168.1.1/30.

ip netns exec site1 bash -e <<NS
ip tunnel add gre1 mode gre local 10.100.0.1 remote 10.200.0.1 ttl 255
ip link set gre1 up
ip addr add 192.168.1.1/30 dev gre1
NS

ip netns exec site2 bash -e <<NS
ip tunnel add gre1 mode gre local 10.200.0.1 remote 10.100.0.1 ttl 255
ip link set gre1 up
ip addr add 192.168.1.2/30 dev gre1
NS

# each site acts as a local router, to route between the lan, the tunnel, and
# the wan interfaces. any traffic for the other sites private network is routed
# via the gre tunnel interface. From there it will be encapluated and and
# routed via wan

ip netns exec site1 bash -e <<NS
sysctl -w net.ipv4.ip_forward=1
ip route add 172.16.200.0/24 via 192.168.1.2 dev gre1
NS

ip netns exec site2 bash -e <<NS
sysctl -w net.ipv4.ip_forward=1
ip route add 172.16.100.0/24 via 192.168.1.1 dev gre1
NS

# each device in the lans, must use the site as its default gateway, so
# that when its traffic reaches the site, it will be routed as described
# above.

ip netns exec lan1 ip route add default via 172.16.100.254 dev eth0

ip netns exec lan2 ip route add default via 172.16.200.254 dev eth0

# connectivity test 3

ip netns exec lan1 ping -c 3 172.16.200.1
# PING 172.16.200.1 (172.16.200.1) 56(84) bytes of data.
# 3 packets transmitted, 3 received, 0% packet loss, time 2077ms

ip netns exec lan2 ping -c 3 172.16.100.1
# PING 172.16.100.1 (172.16.100.1) 56(84) bytes of data.
# 3 packets transmitted, 3 received, 0% packet loss, time 2175ms
