#!/usr/bin/env bash
# 一条命令把 horor-site 的 index.html 同步到两个线上入口，避免只改一边。
#   ./deploy.sh          同步 + 发布
#   ./deploy.sh --check  只检查两边是否一致，不发布
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
HUB="/d/Projects/小游戏"
PLAY="$HUB/games/halcyon/play/index.html"
LIVE1="https://halcyon.gongfpp.icu/"
LIVE2="https://game.gongfpp.icu/halcyon/play/"

cp "$SRC/index.html" "$PLAY"

if [ "${1:-}" = "--check" ]; then
  cd "$HUB" && npm run build >/dev/null
fi

if [ "${1:-}" != "--check" ]; then
  cd "$HUB"
  npm run build
  npm run deploy
  cd "$SRC"
  edgeone makers deploy . -n halcyon
fi

echo
echo "— 校验两个入口 —"
a=$(curl -sS --max-time 20 --noproxy '*' "$LIVE1" | md5sum | cut -d' ' -f1)
b=$(curl -sS --max-time 20 --noproxy '*' --resolve game.gongfpp.icu:443:212.64.11.71 "$LIVE2" | md5sum | cut -d' ' -f1)
echo "halcyon.gongfpp.icu        $a"
echo "game.gongfpp.icu/halcyon/  $b"
if [ "$a" = "$b" ]; then echo "✓ 两边一致"; else echo "✗ 两边不一致"; exit 1; fi
