#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export GOMODCACHE="${GOMODCACHE:-$HOME/go/pkg/mod}"
export GOCACHE="${GOCACHE:-$HOME/Library/Caches/go-build}"

mkdir -p bin docs/screenshots/playwright
go build -o bin/ ./cmd/inventory-server ./cmd/gateway

HTTP_PORT="${HTTP_PORT:-8087}"
bin/inventory-server >bin/pw-server.log 2>&1 & SRV=$!
bin/gateway -http-addr ":${HTTP_PORT}" >bin/pw-gateway.log 2>&1 & GW=$!
cleanup() { kill $SRV $GW 2>/dev/null || true; }
trap cleanup EXIT
sleep 2
curl -sf "http://127.0.0.1:${HTTP_PORT}/v1/copies/copy-1" >/dev/null || { echo "gateway not up"; cat bin/pw-gateway.log; exit 1; }
export PLAYWRIGHT_GATEWAY_PORT="$HTTP_PORT"

STATIC_PORT="${STATIC_PORT:-8765}"
python3 -m http.server "$STATIC_PORT" --directory docs/screenshots/playwright >/dev/null 2>&1 & STATIC=$!
cd scripts
if [ ! -d node_modules/playwright ]; then
  npm init -y >/dev/null 2>&1
  npm install playwright@1.49.1 --no-save
fi
export PW_CHANNEL="${PW_CHANNEL:-chrome}"
export PLAYWRIGHT_STATIC_PORT="$STATIC_PORT"
cleanup_static() { kill $STATIC 2>/dev/null || true; }
trap 'cleanup; cleanup_static' EXIT
PLAYWRIGHT_GATEWAY_PORT="$HTTP_PORT" node playwright-capture.mjs
cd ..
bash scripts/capture-homework-demos.sh

echo "All screenshots under docs/screenshots/"
