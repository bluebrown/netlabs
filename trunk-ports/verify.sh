#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(dirname "$(readlink -f "$0")")
source "$script_dir/../netlib.sh"

assert_ping "host0 can reach host1" host0 192.168.20.100
assert_ping "host1 can reach host0" host1 192.168.10.100
