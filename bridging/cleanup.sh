#!/usr/bin/env bash

ip link del bridge0
ip netns del box0
ip netns del box1
