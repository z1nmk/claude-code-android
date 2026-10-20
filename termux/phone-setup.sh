#!/data/data/com.termux/files/usr/bin/sh
# One-time phone setup through Shizuku (runs as the adb "shell" user):
#  - removes Android background limits so Claude isn't killed (phantom process killer, doze, data saver);
#  - puts socat + scrcpy-server into /data/local/tmp/keep for the hidden virtual display (vdisplay).
# Safe to run again.
SCRCPY_VER=5.0.1
K=/data/local/tmp/keep
S=/sdcard/Download/.claude-keep

if ! ~/rish -c id 2>&1 | grep -q 'uid=2000'; then
  echo "Shizuku не отвечает. Запустите Shizuku и разрешите доступ для Termux, затем повторите: ~/phone-setup.sh"
  exit 1
fi

echo "Снимаю фоновые ограничения Android..."
~/rish -c "
device_config set_sync_disabled_for_tests persistent
device_config put activity_manager max_phantom_processes 2147483647
settings put global settings_enable_monitor_phantom_procs false
for p in com.termux com.termux.boot com.termux.widget moe.shizuku.privileged.api; do
  pm path \$p >/dev/null 2>&1 || continue
  dumpsys deviceidle whitelist +\$p >/dev/null
  cmd appops set \$p RUN_IN_BACKGROUND allow
  cmd appops set \$p RUN_ANY_IN_BACKGROUND allow
done
cmd netpolicy add restrict-background-whitelist $(id -u)
" >/dev/null 2>&1

echo "Готовлю скрытый виртуальный экран (socat + scrcpy-server)..."
# Shell can't read Termux's private files and SELinux blocks app<->shell sockets,
# so the shell user gets its own copy of socat, passed through shared storage.
rm -rf "$S"; mkdir -p "$S" || { echo "Нет доступа к памяти: выполните termux-setup-storage"; exit 1; }
cp "$PREFIX/bin/socat" "$HOME/claude-code-android/phone/tap.sh" "$S/"
for l in libandroid-support.so libcrypto.so.3 libssl.so.3 libreadline.so.8 libncursesw.so.6; do
  [ -f "$PREFIX/lib/$l" ] && cp "$PREFIX/lib/$l" "$S/"
done
curl -fsSL -o "$S/scrcpy-server.jar" \
  "https://github.com/Genymobile/scrcpy/releases/download/v$SCRCPY_VER/scrcpy-server-v$SCRCPY_VER"
~/rish -c "mkdir -p $K && chmod 777 $K && cp $S/* $K/ && chmod 755 $K/socat"
# Copy any other library socat turns out to need
for _ in 1 2 3 4 5 6 7 8; do
  lib=$(~/rish -c "LD_LIBRARY_PATH=$K $K/socat -V 2>&1 >/dev/null" | grep -o 'library "[^"]*" not found' | cut -d'"' -f2 | head -1)
  [ -z "$lib" ] && break
  cp "$PREFIX/lib/$lib" "$S/" && ~/rish -c "cp $S/$lib $K/"
done
rm -rf "$S"
if ~/rish -c "LD_LIBRARY_PATH=$K $K/socat -V" | grep -q 'socat version'; then
  touch ~/.claude-phone-ok
  echo "Готово."
else
  echo "socat не запускается от shell — скрытый экран может не работать."
  exit 1
fi
