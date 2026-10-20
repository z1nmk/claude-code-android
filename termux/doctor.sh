#!/data/data/com.termux/files/usr/bin/sh
# Checks every part of the setup and says what to fix.
good() { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
bad()  { printf '\033[1;31m✗\033[0m %s\n    → %s\n' "$1" "$2"; }

for c in proot-distro socat tmux; do
  command -v $c >/dev/null && good "пакет $c" || bad "нет пакета $c" "pkg install $c"
done
[ -r ~/rish_shizuku.dex ] && good "rish установлен" || bad "нет rish" "запустите установку ещё раз"
if ~/rish -c id 2>&1 | grep -q 'uid=2000'; then good "Shizuku работает и разрешён для Termux"
else bad "Shizuku не отвечает" "откройте Shizuku → «Запустить» через беспроводную отладку; разрешите доступ Termux"; fi
pgrep -f 'TCP-LISTEN:7777' >/dev/null && good "мост rish запущен" || bad "мост rish не запущен" "~/claude-start.sh"
[ -f ~/.claude-phone-ok ] && good "телефон настроен (фон, скрытый экран)" || bad "телефон не настроен" "~/phone-setup.sh"
if proot-distro login ubuntu -- test -x /root/.local/bin/claude 2>/dev/null; then good "Ubuntu + Claude Code"
else bad "Claude Code в Ubuntu не найден" "запустите установку ещё раз"; fi
if pgrep -f 'TCP-LISTEN:7777' >/dev/null; then
  proot-distro login ubuntu -- /usr/local/bin/rish -c id 2>/dev/null | grep -q 'uid=2000' \
    && good "Claude может управлять телефоном (rish из Ubuntu)" \
    || bad "rish из Ubuntu не работает" "перезапустите: ~/claude-stop.sh; ~/claude-start.sh"
fi
tmux has-session -t claude 2>/dev/null && good "Claude запущен (tmux attach -t claude)" || echo "  Claude сейчас не запущен — кнопка «Claude» или ~/claude-start.sh"
