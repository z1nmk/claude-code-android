#!/data/data/com.termux/files/usr/bin/bash
# Claude Code on Android: one-command installer. Run it inside Termux:
#   curl -fsSL https://raw.githubusercontent.com/z1nmk/claude-code-android/main/install.sh | bash
# Safe to run again: it updates scripts and skips what is already installed.
# Everything is inside main() so "curl | bash" reads the whole script before running it.
set -e
REPO=z1nmk/claude-code-android
BRANCH=main
DIR=$HOME/claude-code-android

say()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*"; }

main() {
if [ -z "$PREFIX" ] || [ ! -d /data/data/com.termux ]; then
  echo "Этот скрипт нужно запускать в приложении Termux."; exit 1
fi
case "$(uname -m)" in
  aarch64|x86_64) ;;
  *) echo "Нужен 64-битный телефон (arm64). У вас: $(uname -m)"; exit 1 ;;
esac

say "1/7 Доступ к памяти телефона"
if [ ! -d "$HOME/storage" ]; then
  echo "Сейчас Android спросит разрешение на доступ к файлам — нажмите «Разрешить»."
  termux-setup-storage || true
  for _ in $(seq 30); do [ -d /sdcard/Download ] && ls /sdcard/Download >/dev/null 2>&1 && break; sleep 1; done
fi
ls /sdcard/Download >/dev/null 2>&1 && ok "доступ есть" || warn "доступа к памяти нет — скриншоты не будут работать (можно выдать позже: termux-setup-storage)"

say "2/7 Обновление Termux и установка пакетов (несколько минут)"
export DEBIAN_FRONTEND=noninteractive
APT="-y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold"
pkg update $APT </dev/null
pkg upgrade $APT </dev/null
pkg install $APT proot-distro socat tmux unzip curl </dev/null
ok "пакеты установлены"

say "3/7 Загрузка файлов проекта"
SRC=""
[ -n "${BASH_SOURCE[0]}" ] && [ -f "${BASH_SOURCE[0]}" ] && SRC=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -n "$SRC" ] && [ -f "$SRC/termux/claude-start.sh" ]; then
  [ "$SRC" = "$DIR" ] || { rm -rf "$DIR"; cp -r "$SRC" "$DIR"; }
else
  rm -rf "$DIR" "$TMPDIR/cca"; mkdir -p "$TMPDIR/cca"
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar xz -C "$TMPDIR/cca"
  mv "$TMPDIR"/cca/* "$DIR"; rm -rf "$TMPDIR/cca"
fi
ok "файлы в $DIR"

say "4/7 rish (команды Shizuku из Termux)"
rm -f "$HOME/rish_shizuku.dex"
APK=$(/system/bin/pm path moe.shizuku.privileged.api 2>/dev/null | sed -n 's/^package://p' | head -1)
if [ -n "$APK" ] && [ -r "$APK" ]; then
  unzip -o -j -q "$APK" assets/rish_shizuku.dex -d "$HOME"
else
  [ -z "$APK" ] && warn "Shizuku не найден на телефоне — установите его (см. инструкцию). Пока беру rish из релиза Shizuku."
  URL=$(curl -fsSL https://api.github.com/repos/RikkaApps/Shizuku/releases/latest | grep -o 'https://[^"]*\.apk' | head -1)
  curl -fsSL -o "$TMPDIR/shizuku.apk" "$URL"
  unzip -o -j -q "$TMPDIR/shizuku.apk" assets/rish_shizuku.dex -d "$HOME"; rm -f "$TMPDIR/shizuku.apk"
fi
chmod 400 "$HOME/rish_shizuku.dex"   # Android 14+ refuses to load a writable dex
install -m 700 "$DIR/termux/rish" "$HOME/rish"
ok "rish готов"

say "5/7 Скрипты запуска, автозапуск и кнопки на рабочем столе"
for f in rish-bridge.sh claude-start.sh claude-stop.sh phone-setup.sh doctor.sh; do
  install -m 700 "$DIR/termux/$f" "$HOME/$f"
done
mkdir -p "$HOME/.termux/boot" "$HOME/.shortcuts/tasks"
chmod 700 "$HOME/.shortcuts" "$HOME/.shortcuts/tasks"
install -m 700 "$DIR/termux/boot/claude" "$HOME/.termux/boot/claude"
install -m 700 "$DIR/termux/shortcuts/Claude" "$HOME/.shortcuts/Claude"
install -m 700 "$DIR/termux/shortcuts/tasks/Claude-Stop" "$HOME/.shortcuts/tasks/Claude-Stop"
ok "готово: ~/claude-start.sh, ~/claude-stop.sh, автозапуск, кнопки Claude и Claude-Stop"

say "6/7 Ubuntu и Claude Code (долго: скачивается ~500 МБ)"
if ! proot-distro login ubuntu -- true >/dev/null 2>&1; then
  proot-distro install ubuntu </dev/null
fi
proot-distro login ubuntu --bind "$DIR:/opt/claude-code-android" -- bash /opt/claude-code-android/ubuntu/setup.sh </dev/null
ok "Ubuntu и Claude Code установлены"

say "7/7 Настройка телефона через Shizuku"
if "$HOME/phone-setup.sh"; then
  ok "телефон настроен"
else
  warn "Shizuku ещё не запущен или не разрешён для Termux."
  warn "Запустите Shizuku (см. инструкцию) — настройка выполнится сама при первом запуске Claude."
fi

say "Установка завершена!"
cat <<'TXT'
Дальше:
  1. Добавьте на рабочий стол виджет Termux:Widget → кнопка «Claude».
     (или наберите здесь:  ~/claude-start.sh && tmux attach -t claude )
  2. При первом запуске войдите в аккаунт Claude (ссылка откроется в браузере).
  3. Проверка, что всё работает:  ~/doctor.sh
TXT
}

main "$@"
