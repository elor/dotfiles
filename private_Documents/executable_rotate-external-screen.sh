#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Rotate External Screen
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔄

# Documentation:
# @raycast.description Rotates External Screen
# @raycast.author Erik E. Lorenz

set -e -u

macbook_screen_id="37D8832A-2D66-02CA-B9F7-8F30A301B230" # Macbook Air 13 inch screen
display_id="32B0E444-B833-42A0-9AA2-363425C26F40"        # 32 inch external monitor at WMH 1.21

mode=$(displayplacer list | tail -n 1)

case "$mode" in
'displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1710x1112 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" "id:32B0E444-B833-42A0-9AA2-363425C26F40 res:2160x3840 hz:60 color_depth:8 enabled:true scaling:off origin:(-2160,-2728) degree:90"')
  # mode 2
  displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1710x1112 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" "id:32B0E444-B833-42A0-9AA2-363425C26F40 res:3840x2160 hz:60 color_depth:8 enabled:true scaling:off origin:(-1065,-2160) degree:0"
  ;;
'displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1710x1112 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" "id:32B0E444-B833-42A0-9AA2-363425C26F40 res:3840x2160 hz:60 color_depth:8 enabled:true scaling:off origin:(-1065,-2160) degree:0"')
  # mode 3
  displayplacer "id:32B0E444-B833-42A0-9AA2-363425C26F40+37D8832A-2D66-02CA-B9F7-8F30A301B230 res:3840x2160 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0"
  ;;
*)
  # mode 1
  displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1710x1112 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" "id:32B0E444-B833-42A0-9AA2-363425C26F40 res:2160x3840 hz:60 color_depth:8 enabled:true scaling:off origin:(-2160,-2728) degree:90"
  ;;

esac
