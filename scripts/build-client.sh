#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TSDOWN="${TSDOWN_BIN:-$ROOT/node_modules/.bin/tsdown}"
if [ ! -x "$TSDOWN" ]; then
  CHECKOUT="${DSH_CHECKOUT:-}"
  if [ -n "$CHECKOUT" ] && [ -x "$CHECKOUT/node_modules/.bin/tsdown" ]; then
    TSDOWN="$CHECKOUT/node_modules/.bin/tsdown"
  fi
fi

if [ ! -x "$TSDOWN" ]; then
  echo "build:client: tsdown not found; install dependencies or set DSH_CHECKOUT" >&2
  exit 1
fi

"$TSDOWN"
