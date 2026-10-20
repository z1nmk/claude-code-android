#!/data/data/com.termux/files/usr/bin/sh
# Stops Claude, the hidden display and the rish bridge.
proot-distro login ubuntu -- /usr/local/bin/vdisplay stop >/dev/null 2>&1
tmux kill-session -t claude 2>/dev/null
pkill -f 'TCP-LISTEN:7777'
termux-wake-unlock
