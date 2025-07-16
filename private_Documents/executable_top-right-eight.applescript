#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Move To Top Right Eight TR8
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ↗️

# Documentation:
# @raycast.description Moves the window to the top right of the screen.
# @raycast.author Erik E. Lorenz

tell application "System Events"
    set activeApps to name of application processes whose frontmost is true
    set currentApplication to item 1 of activeApps
    set frontWindow to the first window of application process currentApplication
    set size of frontWindow to { 959, 1067 }
    set position of frontWindow to { 1815, -2135 }
end tell

