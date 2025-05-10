#!/usr/bin/env bash

for pidfile in ./*.pid; do
  sudo kill -SIGTERM "$(cat "$pidfile")"
  rm -f "$pidfile"
done

sudo ip netns del dhcp
sudo ip netns del box
