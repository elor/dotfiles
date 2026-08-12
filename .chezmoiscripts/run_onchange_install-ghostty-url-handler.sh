#!/usr/bin/env bash
#
# Registers a ghostty:// URL scheme on macOS, so a directory link -- in an
# Obsidian note, say -- opens a Ghostty window there.
#
#     [repo](ghostty:///Users/you/Code/some-repo)
#
# Deliberately narrow: the handler only ever changes directory. It takes no
# command to execute, so a link arriving via note sync can open a shell
# somewhere but cannot run anything.
#
# macOS asks nothing, but Obsidian prompts once to trust the scheme and then
# records it in ~/Library/Application Support/obsidian/obsidian.json.
set -euo pipefail

APP_PATH="$HOME/Applications/GhosttyHere.app"
BUNDLE_ID="com.github.elor.ghostty-here"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

# No-op on anything that is not a Mac with Ghostty installed, so this stays safe
# to apply on every machine.
[ "$(uname -s)" = "Darwin" ] || { echo "not macOS -- skipping ghostty:// handler"; exit 0; }
command -v osacompile >/dev/null 2>&1 || { echo "osacompile missing -- skipping ghostty:// handler"; exit 0; }
[ -d /Applications/Ghostty.app ] || { echo "Ghostty not installed -- skipping ghostty:// handler"; exit 0; }

SRC="$(mktemp -t ghostty-here)"
trap 'rm -f "$SRC"' EXIT

cat > "$SRC" <<'APPLESCRIPT'
-- Handles ghostty://<absolute-path> by opening Ghostty with that working
-- directory. Changes directory only; never executes a command from the URL.
on open location this_URL
	set pyCode to "import sys, urllib.parse as u; p = u.urlparse(sys.argv[1]); s = u.unquote(p.netloc + p.path); print(s if s.startswith('/') else '/' + s)"
	set thePath to do shell script "/usr/bin/python3 -c " & quoted form of pyCode & " " & quoted form of this_URL

	if thePath is "" then return
	try
		do shell script "/bin/test -d " & quoted form of thePath
	on error
		display notification thePath with title "Ghostty" subtitle "No such directory"
		return
	end try

	do shell script "/usr/bin/open -na Ghostty --args --working-directory=" & quoted form of thePath
end open location
APPLESCRIPT

rm -rf "$APP_PATH"
mkdir -p "$HOME/Applications"
osacompile -o "$APP_PATH" "$SRC"

PLIST="$APP_PATH/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$PLIST" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$PLIST" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLName string Ghostty directory handler" "$PLIST" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$PLIST" >/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string ghostty" "$PLIST" >/dev/null
# Keeps the applet out of the Dock when it fires.
/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$PLIST" >/dev/null
# osacompile applets ship without a bundle identifier, so Add first and only
# fall back to Set if a future macOS starts providing one.
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID" "$PLIST" >/dev/null 2>&1 \
    || /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$PLIST" >/dev/null

# Ad-hoc signature: locally built, but signing keeps LaunchServices happy after
# the plist rewrite invalidates the applet's original signature.
codesign --force --sign - "$APP_PATH" >/dev/null 2>&1 || true

"$LSREGISTER" -f "$APP_PATH"

echo "installed: $APP_PATH"
echo "try:       open 'ghostty://$HOME'"
