#!/usr/bin/env bash
set -Eeo pipefail

script_dir=$(dirname "$(readlink -f "$0")")
source "$script_dir/../netlib.sh"

assert_ping "h1 can reach h2" h1 172.16.1.200
assert_ping "h1 can reach h4" h4 172.16.2.200
assert_ping "h3 can reach h4" h3 172.16.1.200
assert_ping "h3 can reach h1" h4 172.16.1.100
