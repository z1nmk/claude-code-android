# Usage: sh tap.sh "TEXT" — taps the centre of the first on-screen element whose text
# (or content description) starts with TEXT. Optional 2nd arg: display id.
D=${2:+-d $2}
uiautomator dump ${2:+--display $2} /sdcard/.ui.xml >/dev/null 2>&1
B=$(grep -oE "(text|content-desc)=\"$1[^\"]*\"[^>]*bounds=\"\[[0-9]+,[0-9]+\]\[[0-9]+,[0-9]+\]\"" /sdcard/.ui.xml | grep -oE '\[[0-9]+,[0-9]+\]\[[0-9]+,[0-9]+\]' | head -1)
[ -z "$B" ] && { echo "not found: $1"; exit 1; }
echo "$B" | sed -E 's/\[([0-9]+),([0-9]+)\]\[([0-9]+),([0-9]+)\]/\1 \2 \3 \4/' | { read a b c d; input $D tap $(( (a+c)/2 )) $(( (b+d)/2 )); }
