#!/usr/bin/bash

echo "$(dirname "$0")"

cd "$(dirname "$0")" || exit 1
exec python3 chat.py
