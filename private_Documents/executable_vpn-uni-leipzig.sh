#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title VPN Uni Leipzig
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔐

# Documentation:
# @raycast.description Connect/Disconnect Uni Leipzig VPN
# @raycast.author Erik E. Lorenz

VPN="ULE"

case $(networksetup -showpppoestatus $VPN) in
connected)
  networksetup -disconnectpppoeservice $VPN
  ;;
disconnected)
  networksetup -connectpppoeservice $VPN
  ;;
*) ;;
esac
