#!/bin/bash
#
# teleport user [height]
#
# This probably does not work if you haven't the dynmap plugin installed
# as this delays the teleport until dynmap keeps up.
#
# BTW spams the Bukkit console a lot.

connecter()
{
while	echo OOPS
do
	socat - "unix:/var/tmp/autostart/$USER/bukkit.sock"
done
}

coproc connecter
PROC="$!"
trap 'kill $PROC' 0
IN=${COPROC[0]}
OU=${COPROC[1]}

echo "$PROC $IN $OU"

name="$1"
lv="${2:-100}"

getq()
{
~/bin/nonblocking <&$IN >/dev/null
echo dynmap stats >&$OU || return
while	read -ru$IN -t60 line
do
	case "$line" in
	*'Triggered update queue size:'*)	break;;
	esac
done
line="${line///}"
line="${line##* }"
line="${line%*}"
~/bin/nonblocking <&$IN >/dev/null
let l=0+line
true
}

MIN=1500
setmin()
{
#echo SETMIN "'$1'"
min=$1
[ $MIN -gt $min ] && min=$MIN
}

while	! read -ru$IN t1 line
do
	echo -n .
done

getq || exit
setmin $l

while	z="$lv"
	echo -n "$1@$x $y $z: "
	read -r x y z
do
	~/bin/nonblocking <&$IN
	[ -n "$z" ] && [ 0 -lt "$z" ] && lv="$z"
	echo "tp $1 $x ${z:-$lv} $y" >&$OU
	read -ru$IN -t60 line || echo "OOPS: $?"
	echo "$line"
	read -ru$IN -t60 line || echo "OOPS: $?"
	echo "${line///}"
	if	getq && [ $min -lt $l ]
	then
		echo "============= $min < $l ================="
		sleep 2
		let min+=20
	else
		setmin $l
	fi
	echo -n "$l "
	sleep .1
	~/bin/nonblocking <&$IN >/dev/null
done

