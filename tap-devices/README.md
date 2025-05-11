# TAP Devices

Start the program:

    cc tap.c
    ./a.out

Generating frames:

    arping -i tap0 192.168.0.10

Observing frames:

    sudo tcpdump -i tap0 -e -n -vvv

Inspect ARP table:

    ip neigh show dev tap0

> [!TIP]  
> It is possible to move a tap device to a nother network namespace, but
> the file descriptor has to be opened before the move, and the device
> has to be brought up in the new namespace. This is not done in this
> example.
