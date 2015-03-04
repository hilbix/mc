#!/bin/bash

if	[ 0 = $# ]
then
	echo "Usage: `basename "$0"` USER [SPEED]
	Fly a user to the given game coordinates provided on STDIN.
	(Due to a limitation of bukkit the USER is teleported to the first pos.)
	SPEED defaults to 64, it is the number of blocks to warp the user.
	Coordinates are given EAST SOUTH HEIGHT, HEIGHT defaults to 100.
	USER must be in 'gamemode 1'.
	To find USER, use 'bukkit list'.
	Example:
		scan 1000 1000 | fly admin" >&2
	exit 1
fi

DELTA="${2:-64}"	# 16, 32, 64, ..

delta()
{
  let d="$2-$1"
  [ -$3 -gt $d ] && d=-$3
  [ $3 -lt $d ] && d=$3
}

calc()
{
local v="${!1}"
local w="${!2}"
case "$v" in
'')	let "$1=${w:-0}";;
[d]*)	let "$1=${w:-0}+${v#d}";;
*)	let "$1=0+${v:-${w:-0}}";;
esac
}

ESC=$'\e'
posline="`bukkit "turmites get player.pos $1   " | tail -1`"
posline="${posline%[[:space:]]}"
posline="${posline%"$ESC["[a-z]}"
posline="${posline##*:}"

echo "$posline"
read -r x z y p <<<"$posline"

[ ".$p" = ".$1" ] && let "x=$x" && let "y=$y" && let "z=$z" ||
{
x=
y=
z=100
}
while	c="$z"
	{ [ -z "$x$y" ] || echo "$x $y $z"; } &&
	read -r a b c
do
	if [ -z "$x$y" ]
	then
		x=$a
		y=$b
		z=${c:-$z}
		continue
	fi
	calc a x
	calc b y
	calc c z
#	echo "a=$a b=$b c=$c x=$x y=$y z=$z D=$DELTA" >&2
	while	delta $x $a $DELTA
		let "x+=$d"
		delta $y $b $DELTA
		let "y+=$d"
		delta $z $c 1
		let "z+=$d"
		[ "$x.$y.$z" != "$a.$b.$c" ]
	do
		echo "$x $y $z"
	done
done |
~/bin/teleport "$1"

