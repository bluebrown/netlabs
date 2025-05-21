#!/bin/bash
set -e

commands=(
	# 'ip netns exec host0 tcpdump -i eth0'
	# 'ip netns exec host1 tcpdump -i eth0'
	# 'ip netns exec switch0 tcpdump -i bridge0'
	'ip netns exec router0 tcpdump -i switch.20 -e -vv'
	'ip netns exec router0 tcpdump -i switch0.10 -e -vv'
	'ip netns exec host0 ping -I eth0 192.168.20.100'
)

SESSION="netns_monitor"
WINDOW="monitor"

# Kill session if it already exists to avoid duplicates
if tmux has-session -t "$SESSION" 2>/dev/null; then
	tmux kill-session -t "$SESSION"
fi

# Check terminal size (optional safety check)
MIN_ROWS=$((${#commands[@]} * 3))
MIN_COLS=50
rows=$(tput lines)
cols=$(tput cols)
if [[ $rows -lt $MIN_ROWS || $cols -lt $MIN_COLS ]]; then
	echo "Warning: Your terminal may be too small for ${#commands[@]} panes."
	echo "Recommend at least $MIN_ROWS rows x $MIN_COLS cols. Current: ${rows}x${cols}"
	read -p "Press Enter to continue or Ctrl+C to abort..."
fi

tmux new-session -d -s "$SESSION" -n "$WINDOW"

# Run the first command in the main pane
tmux send-keys -t "$SESSION":"$WINDOW".0 "${commands[0]}" C-m

# For subsequent commands, split and run
for ((i = 1; i < ${#commands[@]}; i++)); do
	tmux split-window -t "$SESSION":"$WINDOW" -v
	tmux select-layout -t "$SESSION":"$WINDOW" tiled
	tmux select-pane -t "$SESSION":"$WINDOW".${i}
	tmux send-keys -t "$SESSION":"$WINDOW".${i} "${commands[i]}" C-m
done

# Final layout to put all in vertical split
tmux select-layout -t "$SESSION":"$WINDOW" even-vertical

# Attach to the session
tmux attach-session -t "$SESSION"
