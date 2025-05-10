# IP Forwarding

Test the connectivity between two hosts:

    sudo ip netns exec box0 ping -I router0 192.168.1.254
    sudo ip netns exec box1 ping -I router0 192.168.0.254
