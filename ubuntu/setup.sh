#!/bin/bash
# Ubuntu side of the install (runs inside proot-distro, called by install.sh).
set -e
SRC=/opt/claude-code-android
export DEBIAN_FRONTEND=noninteractive

echo "Ubuntu: пакеты..."
apt-get update -q
apt-get upgrade -y -q -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold
# socat: rish bridge; jq: settings merge; gh: GitHub; ffmpeg: hidden-display recordings; nano: simple editor
apt-get install -y -q socat curl wget ca-certificates git gh jq python3 unzip ffmpeg nano

echo "Ubuntu: команды управления телефоном (rish, vdisplay, vshot, shot, tap-text)..."
install -m 755 "$SRC"/ubuntu/bin/* /usr/local/bin/

if [ -x /root/.local/bin/claude ]; then
  echo "Claude Code уже установлен: $(/root/.local/bin/claude --version 2>/dev/null)"
else
  echo "Ubuntu: Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
fi
grep -q '.local/bin' /root/.bashrc 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.bashrc

# Settings: keep the user's own values, add ours to the lists
mkdir -p /root/.claude /root/phone
S=/root/.claude/settings.json
if [ -s "$S" ]; then
  jq -s '.[1] * .[0]
    | .permissions.allow = ((.permissions.allow // []) + $new.permissions.allow | unique)
    | .sandbox.excludedCommands = ((.sandbox.excludedCommands // []) + $new.sandbox.excludedCommands | unique)' \
    --argjson new "$(cat "$SRC/ubuntu/settings.json")" "$S" "$SRC/ubuntu/settings.json" > "$S.new" && mv "$S.new" "$S"
else
  cp "$SRC/ubuntu/settings.json" "$S"
fi

# Phone-control instructions for Claude, in a marked block so re-installs replace it
M=/root/.claude/CLAUDE.md
touch "$M"
sed -i '/<!-- claude-code-android:begin -->/,/<!-- claude-code-android:end -->/d' "$M"
{ echo '<!-- claude-code-android:begin -->'; cat "$SRC/ubuntu/CLAUDE.md"; echo '<!-- claude-code-android:end -->'; } >> "$M"
echo "Ubuntu: готово."
