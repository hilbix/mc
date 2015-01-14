#!/bin/bash

OOPS()
{
echo "OOPS: $*" >&2
exit 1
}

let w="0+$1" || OOPS "$1x$2"
let h="0+$2" || OOPS "$1x$2"

[ 4000 -ge $w ] || OOPS w=$w
[ 3000 -ge $h ] || OOPS h=$h

d=200
y=-$h
while [ $y -lt $h ]
do
	echo "-$w $y"
	echo "$w $y"
	let y+=$d
	[ $y -lt $h ] || break

	echo "$w $y"
	echo "-$w $y"
	let y+=$d
done
