#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TSC="${TSC_BIN:-$ROOT/node_modules/.bin/tsc}"
if [ ! -x "$TSC" ]; then
  CHECKOUT="${DSH_CHECKOUT:-}"
  if [ -n "$CHECKOUT" ] && [ -x "$CHECKOUT/node_modules/.bin/tsc" ]; then
    TSC="$CHECKOUT/node_modules/.bin/tsc"
  fi
fi

if [ ! -x "$TSC" ]; then
  echo "typecheck: tsc not found; install dependencies or set DSH_CHECKOUT" >&2
  exit 1
fi

"$TSC" -p tsconfig.json --noEmit
