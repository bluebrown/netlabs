#!/bin/bash

nss=(r1 sw1 sw2 h1 h2 h3 h4)

for ns in "${nss[@]}"; do
  ip netns del "$ns"
done
