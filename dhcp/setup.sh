#!/usr/bin/env bash
set -e

sudo ip netns add dhcp
sudo ip netns add box
sudo ip link add veth0 netns box type veth peer name veth0 netns dhcp
sudo ip netns exec box ip link set veth0 up
sudo ip netns exec dhcp bash -ec "
    ip addr add 192.168.0.1/24 dev veth0
    ip link set veth0 up
    ip link set lo up
    dnsmasq \
      --pid-file=$PWD/dnsmasq.pid \
      --log-facility=$PWD/dnsmasq.log \
      --conf-file=$PWD/dnsmasq.conf
"
