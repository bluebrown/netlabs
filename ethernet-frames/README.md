# Reading Ethernet Frames

Start the program:

    cc tap.c
    ./a.out

Generating frames:

    arping -i tap0 192.168.0.10

Observing frames:

    sudo tcpdump -i tap0 -e -n -vvv

Inspect ARP table:

    ip neigh show dev tap0
