#!/usr/bin/env bash

nss=(
  router0
  switch0
  switch1
  host0
  host1
  host2
  host3
)

for ns in "${nss[@]}"; do
  printf "deleting netns: %s\n" "$ns"
  ip netns del "$ns"
done
