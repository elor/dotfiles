#!/bin/bash

set -e -u

VAULT=~/Documents/Speicherwolke/Notes/

EVENTS=$(obsidian-macos-calendar-bridge 2>/dev/null || echo "")

if [[ -z "$EVENTS" ]]; then
  exit 0
fi

DAILY_PATH="$VAULT$(obsidian daily:path)"

if [[ ! -f "$DAILY_PATH" ]]; then
  obsidian daily
fi

echo "$EVENTS" | sed -i '' '/^#* Meetings$/r /dev/stdin' "$DAILY_PATH"
