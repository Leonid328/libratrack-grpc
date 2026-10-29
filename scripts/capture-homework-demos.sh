#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=docs/screenshots
mkdir -p bin "$OUT"

make smoke 2>&1 | tee "$OUT/06-smoke-all-ok.txt"

go build -o bin/ ./cmd/inventory-server ./cmd/inventory-client ./cmd/gateway
bin/inventory-server >bin/demo-server.log 2>&1 & SRV=$!
bin/gateway >bin/demo-gateway.log 2>&1 & GW=$!
trap 'kill $SRV $GW 2>/dev/null' EXIT
sleep 1.5

bin/inventory-client get copy-1 >"$OUT/01-unary-getcopy.txt" 2>&1
bin/inventory-client -max 3 watch copy-1 >"$OUT/02-server-streaming-watch.txt" 2>&1
bin/inventory-client bulk demo-hw 2 >"$OUT/03-client-streaming-bulk.txt" 2>&1
go test ./... -count=1 >"$OUT/05-go-test.txt" 2>&1

python3 scripts/terminal_png.py "$OUT" || true
echo "Saved under $OUT/"
