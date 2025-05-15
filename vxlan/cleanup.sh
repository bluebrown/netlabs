#!/usr/bin/bash

script_dir=$(dirname "$(readlink -f "$0")")
bash "$script_dir/../routing-and-switching/cleanup.sh"
