#!/bin/bash

"$HOME/bin/autostart.sh"
SOCK="/var/tmp/autostart/$USER/$(basename "$0" .sh).sock"
[ 0 = $# ] && echo '^D (EOF) to exit console:' && exec socat - "unix:$SOCK"

while IFS='' read -t2 -ru6 line; do echo "$line"; done 6< <(ptybufferconnect -np "$*" "$SOCK")

