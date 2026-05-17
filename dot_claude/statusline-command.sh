#!/bin/sh
# Claude Code statusLine command — shows a compact /usage summary
input=$(cat)

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

parts=""

# 5-hour session limit
if [ -n "$five_pct" ]; then
  parts=$(printf "5h:%.0f%%" "$five_pct")
fi

# 7-day weekly limit
if [ -n "$week_pct" ]; then
  week=$(printf "7d:%.0f%%" "$week_pct")
  parts="$parts | $week"
fi

# Context window usage (last)
if [ -n "$used" ]; then
  ctx=$(printf "ctx:%.0f%%" "$used")
  parts="$parts | $ctx"
fi

# Strip leading " | " if earlier segments were empty
parts=$(echo "$parts" | sed 's/^ | //')

printf "%s" "$parts"
