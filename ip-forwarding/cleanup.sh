#!/usr/bin/env bash

for ns in router0 box0 box1; do
  printf "deleting netns: %s\n" "$ns"
  ip netns del "$ns"
done
