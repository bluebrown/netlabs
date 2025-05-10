# DCHP

Dynamic Host Configuration Protocol (DHCP) is a network management
protocol used on Internet Protocol (IP) networks. It allows a server to
automatically assign an IP address and other network configuration
parameters to each device on a network so they can communicate on an IP
network.

## Example

Get the IP address of the host machine:

    sudo ip netns exec box dhclient -pf $PWD/dhclient.pid veth0

Check the IP address:

    sudo ip netns exec box ip -br addr

Check the default gateway:

    sudo ip netns exec box ip -br route

## How it works

The DHCP server listens for DHCPDISCOVER messages from clients. When a
client sends a DHCPDISCOVER message, the server responds with a
DHCPOFFER message, which contains an available IP address and other
configuration parameters. The client then sends a DHCPREQUEST message to
the server, requesting the offered IP address. The server responds with
a DHCPACK message, confirming the assignment of the IP address and other
configuration parameters. The client can then use the assigned IP
address to communicate on the network.
