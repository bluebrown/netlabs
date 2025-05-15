#!/usr/bin/env bash

function netenter() {
  sudo ip netns exec "$1" su -- "$USER" --login
}

export -f netenter

function netinfo() {
  namespaces=$(ip netns list | awk '{print $1}')

  for namespace in $namespaces; do
    printf "\n[%s]\n" "$namespace"

    echo "addresses:"
    sudo ip netns exec "$namespace" ip -br addr show

    echo "routes:"
    sudo ip netns exec "$namespace" ip route show

    if sudo ip netns exec "$namespace" ip link show | grep -q "bridge"; then
      echo "bridge ports:"
      sudo ip netns exec "$namespace" bridge link show
    fi
  done
}

export -f netinfo

function netclean() {
  namespaces=$(ip netns list | awk '{print $1}')

  for namespace in $namespaces; do
    printf "deleting netns: %s\n" "$namespace"
    sudo ip netns del "$namespace"
  done
}

export -f netclean

function assert_ping() {
  local msg="$1"
  local ns="$2"
  local ip="$3"
  local iface="${4:-eth0}"

  printf "\n[*] %s\n" "$msg"
  if ! sudo ip netns exec "$ns" ping -W 1 -c 1 -I "$iface" "$ip" | head -n 2; then
    echo FAIL
    exit 1
  fi

  echo PASS
}

export -f assert_ping
