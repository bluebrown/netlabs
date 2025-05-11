#!/usr/bin/bash
set -e

# the vnet script contains the automation logic
source "$(dirname "$(readlink -f "$0")")/vnet.sh"

# a router to router between two subnets
router::new r1

# a switch for subnet 1, connecting the
# end hosts to the uplink router
switch::new sw1
ns::connect r1 sw1 172.16.1.1/24
ns::new h1 172.16.1.100/24 172.16.1.1
ns::new h2 172.16.1.200/24 172.16.1.1
ns::connect sw1 h1
ns::connect sw1 h2

# another switch for subnet 2
switch::new sw2
ns::connect r1 sw2 172.16.2.1/24
ns::new h3 172.16.2.100/24 172.16.2.1
ns::new h4 172.16.2.200/24 172.16.2.1
ns::connect sw2 h3
ns::connect sw2 h4
