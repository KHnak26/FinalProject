#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PORT=5050

# If port is taken, stop and tell the user (random ports break persistence).
if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port $PORT is already in use. Please free it or change PORT in this script."
  lsof -nP -iTCP:"$PORT" -sTCP:LISTEN || true
  exit 1
fi

echo "Starting Flutter web-server on http://localhost:$PORT"
flutter run -d web-server --web-port "$PORT"
