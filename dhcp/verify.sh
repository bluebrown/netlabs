#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(dirname "$(readlink -f "$0")")
source "$script_dir/../netlib.sh"

ip netns exec box bash <<NS
dhclient -pf "$script_dir/dhclient.pid" veth0
NS

assert_ping "box can ping gateway" box 192.168.0.1 veth0
