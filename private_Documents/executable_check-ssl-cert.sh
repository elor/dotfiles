#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Check TLS Certificate
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🔒
# @raycast.argument1 { "type": "text", "placeholder": "example.com or https://example.com:443" }
# @raycast.packageName Web

# Documentation:
# @raycast.description Show a server's TLS certificate: validity, expiry (with days remaining), issuer and covered domains.
# @raycast.author eve

set -o pipefail

input="$1"

# Strip scheme (https://, http://) and any path/query, then keep host[:port].
hostport="${input#*://}"
hostport="${hostport%%/*}"

host="${hostport%%:*}"
port="${hostport##*:}"
# If no colon was present, hostport == host == port, so default the port.
if [ "$port" = "$hostport" ]; then
  port=443
fi

if [ -z "$host" ]; then
  echo "❌ No host given. Pass something like: example.com  or  https://example.com:443"
  exit 1
fi

echo "🔎 Checking ${host}:${port} …"
echo

# Grab the presented certificate once.
raw=$(echo | openssl s_client -connect "${host}:${port}" -servername "$host" 2>/dev/null)

if [ -z "$raw" ]; then
  echo "❌ Could not connect to ${host}:${port} (no TLS response)."
  exit 1
fi

cert=$(echo "$raw" | openssl x509 2>/dev/null)

if [ -z "$cert" ]; then
  echo "❌ No certificate returned by ${host}:${port}."
  exit 1
fi

# Chain verification result reported by s_client.
verify_line=$(echo "$raw" | grep -m1 "Verify return code")
verify_code=$(echo "$verify_line" | sed -n 's/.*return code: \([0-9]*\).*/\1/p')

if [ "$verify_code" = "0" ]; then
  echo "✅ Certificate is VALID (chain verified, hostname matched)"
else
  echo "⚠️  Chain/hostname NOT verified — ${verify_line#*: }"
fi
echo

# Dates.
end_date=$(echo "$cert" | openssl x509 -noout -enddate | cut -d= -f2)
start_date=$(echo "$cert" | openssl x509 -noout -startdate | cut -d= -f2)

echo "📅 Valid from : $start_date"
echo "📅 Expires    : $end_date"

# Days remaining (BSD date on macOS). openssl uses a space-padded day → %e.
end_epoch=$(date -j -u -f "%b %e %H:%M:%S %Y" "${end_date% GMT}" "+%s" 2>/dev/null)
now_epoch=$(date -u "+%s")

if [ -n "$end_epoch" ]; then
  days_left=$(( (end_epoch - now_epoch) / 86400 ))
  if [ "$days_left" -lt 0 ]; then
    echo "⏳ Status     : EXPIRED $(( -days_left )) day(s) ago ❗"
  elif [ "$days_left" -le 14 ]; then
    echo "⏳ Status     : expires in $days_left day(s) ⚠️"
  else
    echo "⏳ Status     : $days_left day(s) remaining"
  fi
fi
echo

# Who it's for / who signed it.
subject=$(echo "$cert" | openssl x509 -noout -subject | sed 's/^subject=//')
issuer=$(echo "$cert" | openssl x509 -noout -issuer | sed 's/^issuer=//')

echo "🏷  Subject    : $subject"
echo "🏢 Issuer     : $issuer"
echo

# Scope: all domains this cert covers.
san=$(echo "$cert" | openssl x509 -noout -ext subjectAltName 2>/dev/null | grep -v "Subject Alternative Name" | tr -d ' ')
if [ -n "$san" ]; then
  echo "🌐 Covers domains:"
  echo "$san" | tr ',' '\n' | sed 's/^DNS://; s/^/   • /'
fi
