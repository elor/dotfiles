#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Feierabend
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🏡

# Documentation:
# @raycast.description Schließt Apps nach der Arbeit
# @raycast.author Erik E. Lorenz

tell application "Microsoft Teams" to quit
tell application "Obsidian" to quit
tell application "Element" to quit
tell application "Skype for Business" to quit
tell application "zoom.us" to quit
tell application "Microsoft Word" to quit
tell application "Microsoft Excel" to quit
tell application "Microsoft PowerPoint" to quit

do shell script "networksetup -listpppoeservices | while IFS= read -r vpn; do networksetup -disconnectpppoeservice \"$vpn\"; done"

tell application "eduVPN" to quit
