#!/bin/bash
#
# Scans an area by teleporting a dummy around
#
# Example
#	scan 1000 1000 | fly dummy
# To find a possibly dummy:
#	bukkit list
# You probably only should do this with a user in "gamemode 1" like:
#	bukkit gamemode 1 dummy

delta()
{
  let d="$2-$1"
  [ -$3 -gt $d ] && d=-$3
  [ $3 -lt $d ] && d=$3
}

x=
y=
z=100
while	c="$z"
	{ [ -z "$x$y" ] || echo "$x $y $z"; } &&
	read -r a b c
do
	let a="0+${a:=$x}"
	let b="0+${b:=$y}"
	let c="0+${c:-$z}"
	if [ -z "$x$y" ]
	then
		x=$a
		y=$b
		z=$c
		continue
	fi
	while	delta $x $a 16
		let x+=$d
		delta $y $b 16
		let y+="$d"
		delta $z $c 1
		let z+="$d"
		[ "$x.$y.$z" != "$a.$b.$c" ]
	do
		echo "$x $y $z"
	done
done | ~/bin/teleport "$@"

