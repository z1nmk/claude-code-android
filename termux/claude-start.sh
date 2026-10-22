#!/data/data/com.termux/files/usr/bin/sh
# Starts everything for Claude on the phone: rish bridge + Claude Code (remote control) in tmux.
# Claude resumes the most recent conversation (-c); if there is none, it starts a new one.
# Safe to run repeatedly: already running parts are skipped.
termux-wake-lock
command -v socat >/dev/null || pkg install -y socat
command -v tmux >/dev/null || pkg install -y tmux
pgrep -f 'TCP-LISTEN:7777' >/dev/null || nohup ~/rish-bridge.sh >/dev/null 2>&1 &
tmux has-session -t claude 2>/dev/null || \
  tmux new-session -d -s claude 'proot-distro login ubuntu -- bash -lc "mkdir -p /root/phone && cd /root/phone && /root/.local/bin/claude -c --remote-control || /root/.local/bin/claude --remote-control"'
# One-time phone setup if it hasn't happened yet, then re-apply background limits removal
# (phantom process killer etc.); needs Shizuku, harmless if it's not up yet.
[ -f ~/.claude-phone-ok ] || ~/phone-setup.sh >/dev/null 2>&1 &
~/rish -c 'device_config set_sync_disabled_for_tests persistent; device_config put activity_manager max_phantom_processes 2147483647; settings put global settings_enable_monitor_phantom_procs false' >/dev/null 2>&1 &
