#!/usr/bin/env bash
set -Eeo pipefail

script_dir=$(dirname "$(readlink -f "$0")")
source "$script_dir/../netlib.sh"

assert_ping "box0 can reach box1" box0 192.168.1.254 router0
assert_ping "box1 can reach box0" box1 192.168.0.254 router0
