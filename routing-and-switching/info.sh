#!/usr/bin/env bash
set -e

namespaces=(router0 switch0 switch1 host0 host1 host2 host3)
commands=("ip -br addr" "ip route")

for namespace in "${namespaces[@]}"; do
  printf "\n[%s]\n" "$namespace"
  for command in "${commands[@]}"; do
    echo "$ $command"
    sudo ip netns exec "$namespace" bash -ec "$command"
  done
done
