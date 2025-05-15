#!/usr/bin/env bash

for pidfile in ./*.pid; do
  kill -SIGTERM "$(cat "$pidfile")"
  rm -f "$pidfile"
done

ip netns del dhcp
ip netns del box
