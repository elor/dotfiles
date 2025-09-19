#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Move To Bottom Right Eight BR8
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ↘️

# Documentation:
# @raycast.description Moves and positions the window
# @raycast.author Erik E. Lorenz

tell application "System Events"
    set activeApps to name of application processes whose frontmost is true
    set currentApplication to item 1 of activeApps
    set frontWindow to the first window of application process currentApplication
    set output to do shell script "PATH=~/.local/bin:/usr/bin:/opt/homebrew/bin position-eights 8"
    set tid to AppleScript's text item delimiters
    set AppleScript's text item delimiters to " "
    set { w, h, x, y } to text items of output
    set AppleScript's text item delimiters to tid
    # log w & " " & h & " " & x & " " & y
    set position of frontWindow to { x, y }
    set size of frontWindow to { w, h }
end tell

