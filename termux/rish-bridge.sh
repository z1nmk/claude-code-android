#!/data/data/com.termux/files/usr/bin/sh
# Shizuku bridge for Claude in Ubuntu. Stop with Ctrl+C.
# Proot cannot run /system/bin binaries, so rish runs here in Termux and Ubuntu talks to it over TCP.
command -v socat >/dev/null || pkg install -y socat
echo "rish bridge on 127.0.0.1:7777 (Ctrl+C to stop)"
exec socat TCP-LISTEN:7777,bind=127.0.0.1,reuseaddr,fork EXEC:"$HOME/rish",stderr
