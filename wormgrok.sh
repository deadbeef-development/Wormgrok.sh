#!/bin/bash

# Use current directory
WORKDIR=$(pwd)

# Create the exit_wormgrok.sh script in /tmp
cat > /tmp/exit_wormgrok.sh <<'EOF'
#!/bin/bash

# Get the session name
SESSION_NAME="Wormgrok"

# Gracefully exit ngrok
tmux send-keys -t $SESSION_NAME:0.0 C-c

# Gracefully exit Python HTTP server
tmux send-keys -t $SESSION_NAME:0.1 C-c

# Optional: Clean any other necessary services or tasks
echo "Stopping Wormgrok..."

# Delay to ensure commands have been sent
sleep 2

# Kill the session after a short delay to clean up
tmux kill-session -t $SESSION_NAME
EOF

# Make the script executable
chmod +x /tmp/exit_wormgrok.sh

# Set the port variable
PORT=8080

# Start tmux session
tmux new-session -d -s Wormgrok

# Split the window into two horizontal panes
tmux split-window -h

# Split the right pane vertically to make space for the Bash shell
tmux select-pane -t 0
tmux split-window -v

# Pane 0: ngrok
tmux select-pane -t 0
tmux send-keys "ngrok http $PORT" C-m

# Pane 1: Python HTTP server
tmux select-pane -t 1
tmux send-keys "python3 -m http.server --directory $WORKDIR $PORT" C-m

# Pane 2: Bash shell
tmux select-pane -t 2
tmux send-keys "cd $WORKDIR" C-m
tmux send-keys "ls -la" C-m
tmux send-keys "alias exit-wormgrok='/tmp/exit_wormgrok.sh'" C-m
tmux send-keys "# Use exit-wormgrok to stop." C-m
tmux send-keys C-m

# Attach to the tmux session
( exec </dev/tty; exec <&1; tmux attach-session -t Wormgrok )
