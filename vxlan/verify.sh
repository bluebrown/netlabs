#!/usr/bin/env/bash

script_dir=$(dirname "$(readlink -f "$0")")
source "$script_dir/../netlib.sh"

assert_ping "host1 can reach host3" host1 172.16.0.101
assert_ping "host3 can reach host1" host3 172.16.0.100
