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
# @raycast.description Show a server's TLS certificate: validity, expiry (with days remaining), issuer, covered domains, full chain, and any mutual-TLS client-CA request.
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

# Grab the presented certificate + full chain + handshake details once.
# 2>&1 keeps the handshake info (verify code, acceptable client-CA names) that
# openssl prints to stderr; -showcerts includes every cert the server sends.
# -msg exposes the raw handshake messages so we can reliably detect a
# CertificateRequest (mutual TLS) — the summary lines alone can't distinguish it.
raw=$(echo | openssl s_client -connect "${host}:${port}" -servername "$host" -showcerts -msg 2>&1)

if ! echo "$raw" | grep -q "BEGIN CERTIFICATE"; then
  echo "❌ Could not get a certificate from ${host}:${port}."
  echo "$raw" | grep -iE "connect:|error|alert|refused" | head -3 | sed 's/^/   /'
  exit 1
fi

# Leaf (first) cert.
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
echo

# Full chain the server presented (leaf → intermediates → maybe root).
chain_pem=$(echo "$raw" | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p')
chain=$(echo "$chain_pem" | openssl crl2pkcs7 -nocrl -certfile /dev/stdin 2>/dev/null \
  | openssl pkcs7 -print_certs -noout 2>/dev/null)

if [ -n "$chain" ]; then
  echo "🔗 Chain presented by server:"
  n=0
  echo "$chain" | grep '^subject=' | sed 's/^subject=//' | while IFS= read -r s; do
    n=$((n + 1))
    echo "   $n. $s"
  done
fi
echo

# Mutual TLS: does the server ask the client for a certificate, and from which CAs?
# Detected via the actual CertificateRequest handshake message (from -msg), which
# is the reliable signal — this is the key check for Foreman-style
# "tlsv1 alert unknown ca" issues, where the server rejects the client's cert.
if echo "$raw" | grep -q "CertificateRequest"; then
  echo "🤝 Mutual TLS: server REQUESTS a client certificate."
  ca_names=$(echo "$raw" | awk '
    /Acceptable client certificate CA names/ {flag=1; next}
    /Client Certificate Types|Requested Signature Algorithms|Shared Requested|Peer signing digest|Server Temp Key|^---/ {flag=0}
    flag')
  if [ -n "$(echo "$ca_names" | tr -d '[:space:]')" ]; then
    echo "   Client certs are only accepted if signed by one of these CAs:"
    echo "$ca_names" | sed 's/^[[:space:]]*//; s/^/   • /'
  else
    echo "   Server sent no acceptable-CA hints, so we can't list them remotely."
    echo "   If your client cert is rejected (tlsv1 alert unknown ca), the server's"
    echo "   ssl_ca_file simply doesn't trust the CA that signed your client cert."
  fi
else
  echo "🤝 No client certificate requested (one-way TLS)."
fi
