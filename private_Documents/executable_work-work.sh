#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Work Work
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 💼

# Documentation:
# @raycast.description Startet Apps für die Arbeit
# @raycast.author Erik E. Lorenz

started=0

# Startet die App nur, wenn sie noch nicht läuft. Laufende Apps bleiben
# unangetastet: kein neues Fenster, kein Fokusklau.
start_unless_running() {
	local app="$1" bundle_id
	bundle_id=$(osascript -e "id of app \"$app\"" 2>/dev/null)
	if [ -z "$bundle_id" ]; then
		echo "work-work: App nicht gefunden: $app" >&2
		return
	fi
	if lsappinfo find "bundleid=$bundle_id" | grep -q .; then
		return
	fi
	open -a "$app" && started=$((started + 1))
}

start_unless_running Mail
start_unless_running "Microsoft Teams"
start_unless_running Obsidian
start_unless_running Element
start_unless_running "Skype for Business"
start_unless_running Zotero

case $started in
0) echo "Alle Apps liefen schon" ;;
1) echo "1 App gestartet" ;;
*) echo "$started Apps gestartet" ;;
esac
