#!/usr/bin/bash
set -e

default_iface=eth0
bridge_iface=bridge0

function ns::new() {
  local ns=$1
  local addr=${2:-}
  local gw=${3:-}

  ip netns add "$ns"
  ip netns exec "$ns" ip link set lo up

  ip link add "$ns" type veth peer name "$default_iface" netns "$ns"
  ns::init_iface "$ns" "$default_iface" "$addr"

  if [ -n "$gw" ]; then
    ip netns exec "$ns" ip route add default via "$gw"
  fi
}

function ns::init_iface() {
  local ns=$1
  local iface=$2
  local addr=${3:-}

  ip netns exec "$ns" ip link set "$iface" up

  addr_iface=$iface

  if ns::is_switch "$ns"; then
    switch::add_port "$ns" "$iface"
    addr_iface="$bridge_iface"
  fi

  if [ -n "$addr" ]; then
    ip netns exec "$ns" ip addr add "$addr" dev "$addr_iface"
  fi
}

function ns::is_switch() {
  local ns=$1
  if ip netns exec "$ns" ip link show "$bridge_iface" &>/dev/null; then
    return 0
  else
    return 1
  fi
}

function ns::connect() {
  local ns=$1
  local downstream=$2
  local addr=${3:-}

  ip link set "$downstream" netns "$ns"
  ns::init_iface "$ns" "$downstream" "$addr"
}

function router::new() {
  local router=$1
  local addr=${2:-}
  local gw=${3:-}

  ns::new "$router" "$addr" "$gw"

  ip netns exec "$router" sysctl -w net.ipv4.ip_forward=1
}

function switch::new() {
  local switch=$1
  local addr=${2:-}
  local gw=${3:-}

  ns::new "$switch"

  ip netns exec "$switch" ip link add "$bridge_iface" type bridge
  ip netns exec "$switch" ip link set "$bridge_iface" up
  ip netns exec "$switch" ip link set "$default_iface" master "$bridge_iface"

  if [ -n "$addr" ]; then
    ip netns exec "$switch" ip addr add "$addr" dev "$bridge_iface"
  fi

  if [ -n "$gw" ]; then
    ip netns exec "$switch" ip route add default via "$gw"
  fi
}

function switch::add_port() {
  local switch=$1
  local iface=$2

  ip netns exec "$switch" ip link set "$iface" master "$bridge_iface"
}
