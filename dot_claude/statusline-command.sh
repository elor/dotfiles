#!/bin/sh
# Claude Code statusLine command — shows a compact /usage summary
input=$(cat)


used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

parts=""

# 5-hour session limit
if [ -n "$five_pct" ]; then
  label=$(printf "5h:%.0f%%" "$five_pct")
  if [ -n "$five_resets_at" ]; then
    reset_time=$(date -r "$five_resets_at" +"%H:%M")
    label=$(printf "%s (%s)" "$label" "$reset_time")
  fi
  parts="$label"
fi

# 7-day weekly limit
if [ -n "$week_pct" ]; then
  week=$(printf "7d:%.0f%%" "$week_pct")
  parts="$parts | $week"
fi

# Context window usage (last)
if [ -n "$used" ] && [ "$used" != "0" ]; then
  ctx=$(printf "ctx:%.0f%%" "$used")
  parts="$parts | $ctx"
fi

# Strip leading " | " if earlier segments were empty
parts=$(echo "$parts" | sed 's/^ | //')

printf "%s" "$parts"
