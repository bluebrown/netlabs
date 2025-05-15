#!/usr/bin/env bash
for ns in router0 switch0 host0 host1; do
  ip netns del "$ns"
done
