#!/bin/bash

SOCK="/var/tmp/autostart/$USER/bukkit.sock"
[ 0 = $# ] && echo '^D (EOF) to exit console:' && exec socat - "unix:$SOCK"

while read -t1 -ru6 line; do echo "$line"; done 6< <(ptybufferconnect -np "$*" "$SOCK")

