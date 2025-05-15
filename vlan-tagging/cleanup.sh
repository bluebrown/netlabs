#!/usr/bin/env bash

ip link del bridge0

for n in {0..2}; do
  ip netns del "box$n"
done
