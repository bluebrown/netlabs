#!/usr/bin/env bash
set -e

ip netns add dhcp
ip netns add box
ip link add veth0 netns box type veth peer name veth0 netns dhcp

ip netns exec box ip link set veth0 up

ip netns exec dhcp bash <<NS
ip addr add 192.168.0.1/24 dev veth0
ip link set veth0 up
ip link set lo up
dnsmasq \
  --pid-file=$PWD/dnsmasq.pid \
  --log-facility=$PWD/dnsmasq.log \
  --conf-file=$PWD/dnsmasq.conf
NS
