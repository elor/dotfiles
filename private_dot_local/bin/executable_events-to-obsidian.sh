#!/bin/bash

# Fügt die heutigen Termine unter "Meetings" in die Daily Note ein.
# Idempotent: Termine, die im Abschnitt schon stehen, werden übersprungen –
# als Titelzeile ("HHMM Titel") oder, nach Anlegen der Minutes, als Link
# ("[[YYYY-MM-DD HHMM Titel]]", Sonderzeichen im Dateinamen ersetzt).
# Neue Termine werden chronologisch einsortiert.

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

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
echo "$EVENTS" > "$TMP/events"

awk -v evfile="$TMP/events" '
  # Vergleichsschlüssel "HHMM titel" einer Titel- oder Minutes-Link-Zeile, sonst ""
  function evkey(s) {
    if (s ~ /^[[:space:]]*([-*][[:space:]]+)?\[\[[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9][0-9][0-9] /) {
      sub(/^[^[]*\[\[[^ ]+ /, "", s); sub(/[]|#].*$/, "", s)
    } else if (s !~ /^[0-9][0-9][0-9][0-9] /) return ""
    gsub(/[[:punct:]]/, "", s); gsub(/[[:space:]]+/, " ", s); sub(/ $/, "", s)
    return s
  }
  function emit(k) { if (!done[k]) { print blk[k]; done[k] = 1 } }
  BEGIN {
    m = 0
    while ((getline l < evfile) > 0) {
      if (l ~ /^[0-9][0-9][0-9][0-9] /) { m++; key[m] = evkey(l); blk[m] = l }
      else if (m) blk[m] = blk[m] "\n" l
    }
  }
  { line[NR] = $0 }
  END {
    n = NR; h = 0
    for (i = 1; i <= n; i++) if (line[i] ~ /^#+ Meetings$/) { h = i; break }
    if (!h) { for (i = 1; i <= n; i++) print line[i]; exit }
    e = n + 1
    for (i = h + 1; i <= n; i++) if (line[i] ~ /^#/) { e = i; break }

    found = 0; last = h
    for (i = h + 1; i < e; i++) {
      ek[i] = evkey(line[i])
      if (ek[i] != "") { have[ek[i]] = 1; found = 1 }
      if (line[i] !~ /^[[:space:]]*$/) last = i
    }
    for (k = 1; k <= m; k++) if (key[k] in have) done[k] = 1
    if (!found) last = h

    for (i = 1; i <= n; i++) {
      if (i > h && i < e && ek[i] != "") {
        t = substr(ek[i], 1, 4)
        for (k = 1; k <= m; k++) if (substr(key[k], 1, 4) < t) emit(k)
      }
      print line[i]
      if (i == last) for (k = 1; k <= m; k++) emit(k)
    }
  }
' "$DAILY_PATH" > "$TMP/note"

if ! cmp -s "$TMP/note" "$DAILY_PATH"; then
  cat "$TMP/note" > "$DAILY_PATH"
fi
