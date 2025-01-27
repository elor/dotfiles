#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Plenum
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📝

# Documentation:
# @raycast.description Converts dezentrale plenum to mikiwedia
# @raycast.author Erik E. Lorenz
# @raycast.authorURL tuvero.de

set -e -u

pbpaste >/tmp/plenum.md
pandoc -f markdown -t mediawiki /tmp/plenum.md | pbcopy
rm /tmp/plenum.md

echo "clipboard converted into mediawiki"
