#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(dirname "$(readlink -f "$0")")
source "$script_dir/../netlib.sh"

assert_ping "host0 can reach host1" host0 192.168.0.101
assert_ping "host0 can reach host3" host0 192.168.1.101
assert_ping "host2 can reach host3" host2 192.168.1.101
assert_ping "host2 can reach host1" host2 192.168.0.101
