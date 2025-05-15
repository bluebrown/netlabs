#!/usr/bin/env bash
set -Eeo pipefail

script_dir=$(dirname "$(readlink -f "$0")")
source "$script_dir/../netlib.sh"

ip link set dev bridge0 type bridge vlan_filtering 1
bridge vlan add dev veth0 vid 10 pvid untagged
bridge vlan add dev veth1 vid 10 pvid untagged
bridge vlan add dev veth2 vid 20 pvid untagged

ip netns exec box0 bash <<NS
printf "\n[*] box0 can ping box1\n"
ping -W 1 -c 1 -I "eth0" 192.168.1.101 | head -n 2

printf "\n[*] box0 cannot ping box2\n"
if ping -W 1 -c 1 -I "eth0" 192.168.1.102; then
  exit 1
fi
NS
