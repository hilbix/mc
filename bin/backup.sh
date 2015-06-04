#!/bin/bash

OOPS()
{
echo "OOPS: $*" >&2
exit 1
}

OUT="$HOME/backup"
BACK="$OUT/mc.attic"

ATTIC="`which attic`" || OOPS "backup needs attic installed: sudo apt-get install attic # for Debian"
[ -d "$OUT" ] || OOPS "missing dir $OUT: mkdir '$OUT'"
[ -f "$BACK/README" ] || OOPS "missing attic repo $BACK: attic init '$BACK'"
read -r line < "$BACK/README" || OOPS "cannot access $$BACK/README"
[ '.This is an Attic repository' = ".$line" ] || OOPS "$BACK is not an attic repository"

need()
{
[ -n "$1" ] || OOPS "need additional parameter: $2"
}

run()
{
case "$1" in
'')		run prune; run backup;;
backup)		attic create -v -s "$BACK::mc-`date +%Y%m%d-%H%M%S`" .;;
list|check)	attic "$1" -v "$BACK";;
info)		need "$2" YYYYMMDD-HHMMSS; attic -v "$BACK::mc-$2";;
prune)		attic prune -v -s --keep-within 1w --keep-daily 60 --keep-weekly 15 --keep-monthly 12 --keep-yearly -1 -p mc-;;
esac
}

run "$@"

