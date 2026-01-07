#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

flutter run -d chrome \
  --web-port 5050 \
  --web-browser-flag=--user-data-dir="${PWD}/.chrome_profile"
