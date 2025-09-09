#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Link To Obsidian
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📧

# Documentation:
# @raycast.description Inserts the link to the currently selected Mail or Finder item into the current position in obsidian
# @raycast.author Erik E. Lorenz

tell application "System Events"
  if frontmost of process "Finder" is true then
      tell application "Finder"
          set selectedItems to selection
          set selectedItem to item 1 of selectedItems
          set itemURL to (URL of selectedItem) as string
          set itemName to name of selectedItem
          set linkText to "[🖇️ " & itemName & "](" & itemURL & ")"

          set the clipboard to linkText
      end tell
  else
    set frontmost of process "Mail" to true

    tell application "Mail"
      set selectedMessages to selection
      set theMessage to item 1 of selectedMessages
      set messageid to message id of theMessage
      set messagesubject to subject of theMessage
      set senderName to extract name from sender of theMessage without email
      set itemURL to "message://" & "%3c" & messageid & "%3e"
      set linkText to "[✉️ " & messagesubject & "](" & itemURL & ")"

      -- Parse sender name
      if senderName contains "," then
        set lastname to word 1 of senderName
        set firstname to text ((offset of "," in senderName) + 2) thru -1 of senderName
        set senderName to trim_text(firstname) & " " & trim_text(lastname)
      end if

      set senderText to "[[" & senderName & "]]"

      set the clipboard to linkText & " von " & senderText
    end tell
  end if

  set frontmost of process "Obsidian" to true
  keystroke "v" using command down
end tell

on trim_text(theText)
  set theText to do shell script "echo \"" & theText & "\" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'"
  return theText
end trim_text
