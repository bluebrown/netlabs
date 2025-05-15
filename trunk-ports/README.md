# Trunk Ports

Verify inter vlan routing:

    ip netns exec host0 ping -c 3 -I eth0 192.168.20.100
    ip netns exec host1 ping -c 3 -I eth0 192.168.10.100
