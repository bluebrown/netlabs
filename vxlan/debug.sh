#!/bin/bash
set -e

# run this script with sudo

SESSION="network_debug"

tmux new-session -d -s $SESSION
tmux send-keys -t $SESSION "ip netns exec router0 tcpdump -i switch0 -nn -vv" C-m

tmux split-window -h -t $SESSION
tmux send-keys -t $SESSION "ip netns exec router0 tcpdump -i switch1 -nn -vv" C-m

tmux split-window -v -t $SESSION:0.1
tmux send-keys -t $SESSION "ip netns exec host1 ping -c 3 -I eth0 172.16.0.101" C-m

tmux select-layout -t $SESSION tiled
tmux attach-session -t $SESSION
