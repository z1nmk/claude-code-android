#!/data/data/com.termux/files/usr/bin/sh
# Removes the scripts, buttons and autostart. Ubuntu itself is kept unless you pass --all.
~/claude-stop.sh 2>/dev/null
rm -f ~/rish ~/rish_shizuku.dex ~/rish-bridge.sh ~/claude-start.sh ~/claude-stop.sh ~/phone-setup.sh ~/doctor.sh \
      ~/.claude-phone-ok ~/.termux/boot/claude ~/.shortcuts/Claude ~/.shortcuts/tasks/Claude-Stop
[ "$1" = "--all" ] && proot-distro remove ubuntu
echo "Удалено. Ubuntu с Claude Code: $( [ "$1" = "--all" ] && echo удалена || echo 'оставлена (удалить: sh ~/claude-code-android/uninstall.sh --all)')"
rm -rf ~/claude-code-android
