#!/usr/bin/env bash

ip link del bridge0
for ns in box0 box1; do
  ip netns del $ns
done
