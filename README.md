# Virtual Networking Examples

Each directory contains a different networking example. All of the
examples have a `setup.sh` and `cleanup.sh` file. These are indeted to
be used before and after running the example.

    bash -x setup.sh
    bash -x cleanup.sh

## netlib.sh

This repository contains a collection a [ultility script](./netlib.sh)
that is meant to be sourced in your shell. It contains a collection of
functions that are useful for inspecting and debugging network
topologies.

    source netlib.sh
    netinfo
