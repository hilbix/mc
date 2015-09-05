#!/bin/bash

OOPS()
{
echo "OOPS: $*" >&2
exit 1
}

OUT="$HOME/backup"
BACK="$OUT/mc.attic"
REST="$HOME/restore"

ATTIC="`which attic`" || OOPS "backup needs attic installed: sudo apt-get install attic # for Debian"
[ -d "$OUT" ] || OOPS "missing dir $OUT: mkdir '$OUT'"
[ -f "$BACK/README" ] || OOPS "missing attic repo $BACK: attic init '$BACK'"
read -r line < "$BACK/README" || OOPS "cannot access $BACK/README"
[ '.This is an Attic repository' = ".$line" ] || OOPS "$BACK is not an attic repository"

need()
{
[ -n "$1" ] || OOPS "need additional parameter: $2"
}

x()
{
echo "running: $*"
"$@"
ret=$?
echo "result=$ret $*"
return $ret
}

run()
{
case "$1" in
'')		OOPS "try: $0 help";;
help)		echo "Usage: $0 command [args..]"
		echo "	Possible commands (for this wrapper around attic) are:"
		echo "	backup		do a backup of the current directory"
		echo "	prune		delete exzess backups (day=60 week=15 mon=12 yr=1)"
		echo "	auto		prune + backup"
		echo "	check		check integrity of backup (warning: takes ages)"
		echo "	list		list all backups"
		echo "	info X		show details of some backup"
		echo "	delete X	delete a backup"
		echo "	mount		mount archives to ~/restore"
		exit;;
auto)		run prune; run backup;;
backup)		x attic create -v -s "$BACK::mc-`date +%Y%m%d-%H%M%S`" "$(readlink -e .)";;
list|check)	x attic "$1" -v "$BACK";;
info|delete)	need "$2" YYYYMMDD-HHMMSS
		x attic "$1" -v "$BACK::mc-${2#mc-}";;
prune)		x attic prune -v -s --keep-within 1w --keep-daily 60 --keep-weekly 15 --keep-monthly 12 --keep-yearly -1 -p mc- "$BACK";;
mount)		mkdir -p "$REST"
		mountpoint "$REST" ||
		x attic mount "$BACK" "$REST";;
*)		OOPS "unknown command $1";;
esac
}

run "$@"

