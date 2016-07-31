#!/bin/bash

WAIT=10

SERVER=spigot.jar

HERE="$PWD"
DIR="$(basename "$0" .sh)"

BACKUP="$HERE/bin/backup.sh"
MOVER="$HERE/bin/mover.sh"

CONF="$HERE/$DIR"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}/$DIR/${CONF#$HOME}-settings"

EULA=eula.txt
AUTOBACKUP=.autobackup

log()
{
echo "`date +%Y%m%d-%H%M%S` $*" >&2 || exit 1
}

OOPS()
{
log "$*"
exit 1
}

mover()
{
wait
"$MOVER" &
log "started $MOVER in background, PID $!"
sleep 1
}

backup()
{
[ -f .backupped ] && log "already backed up, to rerun: rm -f '$PWD/.backupped'" && return
"$BACKUP" "$@" && touch .backupped && log 'Backup successful' && [ -x "$MOVER" ] && mover
}

autobackup()
{
[ -f "$AUTOBACKUP" ] || return
backup auto
}

: ok file key sep value
ok()
{
grep -q "^[[:space:]]*$2[[:space:]]*$3[[:space:]]*$4[[:space:]]*$" "$1"
}

: modify file key sep value
modify()
{
ok "$@" && return
sed -i "s|^\\([[:space:]]*\\)$2[[:space:]]*$3.*$|\\1$2$3$4|" "$1"
ok "$@" || echo "$2$3$4" >> "$1"
log "changed $1: $2$3$4"
}

: agree what file key sep val
agree()
{
[ 5 = $# ] || OOPS agree needs 5 arguments
ok "${@:2}" && return
echo ========================================================================
cat "$2" || return
echo ========================================================================
echo -n "Do you agree to $1?  Please type AGREE to agree: "
read agree || return
[ .AGREE = ".$agree" ] || return
modify "${@:2}"
}

: yesno 1question 2file 3key 4sep 5yes 6no
yesno()
{
[ 6 = $# ] || OOPS yesno needs 6 arguments
was="y/N"
[ ".$conf" = ".$5" ] && was="Y/n"
echo -n "$1 [$was]? "
read -r res || return
case "$res" in
y*|Y*)	conf="$5";;
n*|N*)	conf="$6";;
esac
}

: check 1mode 2typefn 3question 4file 5key 6sep 7val..
check()
{
[ -f "$CONF" ] || touch "$CONF"
config="$4 $5"
conf="$(sed -n "s|^$config	||p" "$CONF")"
ok "$4" "$5" "$6" "${conf:-$7}"
prev=$?
if	$1 && [ -n "$conf" ]
then
	[ 0 = $prev ] && return
else
	# takes conf/prev
	"${@:2}"
	# returns conf
fi

[ -n "$conf" ] || return
modify "$4" "$5" "$6" "$conf"
modify "$CONF" "$config" "	" "$conf"
}

: setup true/false # interaction
setup()
{
[ -f "$SERVER" ] || return

# Do we need the EULA?
shot=false
[ -f "$EULA" ] || shot=true
$shot && populate		# run once to populate directory
check "$1" agree EULA "$EULA" eula = true
$shot && populate		# run again after EULA to populate rest of files

check "$1" yesno 'Prevent plugin metrics from phoning home' plugins/PluginMetrics/config.yml opt-out ': ' true false
check "$1" yesno 'Prevent snooper from phoning home' server.properties snooper-enabled = false true
check "$1" yesno 'Disable dynmap webservice' plugins/dynmap/configuration.txt disable-webserver ': ' true false
}

# Starte the server to populate files etc.
: populate
populate()
{
# Luckily, that works
echo stop | start
}

: start
start()
{
rm -f .backupped
log STARTING server
JAVA=java
JAVAMEM=3G
JAVARGS=
[ -x startup-hook.sh ] && . startup-hook.sh
[ -n "$JAVARGS" ] || JAVARGS="-Xms$JAVAMEM -Xmx$JAVAMEM"
$JAVA $JAVARGS -jar "$SERVER"
log TERMINATED with error code $?
}

mkdir -pm0700 "$(dirname "$CONF")" && : >> "$CONF" || OOPS "cannot create $CONF"

cd "$DIR" || OOPS "missing $DIR"

log $DIR CONTROL started

autobackup
setup true

auto=:
while	
	[ -f "$AUTOBACKUP" ] && echo Autobackup is ON
	log =================================================
	log = Please give CMD or hit Return to start server =
	log =================================================
	if	wait=
		[ -f .RUNNING ]
	then
		if $auto
		then
			echo "Autostarting server in $WAIT seconds"
			wait="-t$WAIT"
		else
			echo "halted, NOT autostarting server in $WAIT seconds"
		fi
	fi
	read -r $wait cmd || echo TIMEOUT >&0 || exit 1
do
	[ -f "$SERVER" ] || OOPS "missing $SERVER ($PWD)"
	case "$cmd" in
	''|start|run)
		autobackup
		setup true
		start
		autobackup
		;;
	exit|stop)	break;;
	move)	mover; continue;;
	wait)	echo Waiting; wait; continue;;
	halt)	auto=false; continue;;
	noauto|noautostart)	rm -f .RUNNING; continue;;
	backup)	backup backup; continue;;
	bkon)	touch "$AUTOBACKUP"; continue;;
	bkoff)	rm -f "$AUTOBACKUP"; continue;;
	list|info|check|prune)	"$BACKUP" "$cmd";;
	info' '*)		"$BACKUP" "${cmd%% *}" "${cmd#* }";;
	auto|autostart)	touch .RUNNING;;
	setup|settings)	setup false;;
	*)	echo "Unknown command.  Possible control-CMDs:"
		echo "	start	(or empty line) to start server"
		echo "	stop	leave control (will be restarted in a minute by cron)"
		echo "	auto	autostart server after stopped"
		echo "	noauto	do not autostart (permanently)"
		echo "	halt	do not autostart (once)"
		echo "	setup	Alter settings"
		[ -x "$BACKUP" ] &&
		echo "	backup	do a backup (if backup script is installed)" &&
		echo "	bkoff	switch autobackup off" &&
		echo "	bkon	switch autobackup on" &&
		echo "	list	list backups" &&
		echo "	info	get info on backup" &&
		echo "	prune	prune backups (included in autobackup)" &&
		echo "	check	check backup archive (warning: this takes very long)" &&
		[ -x "$MOVER" ] &&
		echo "	move	start data mover again (to transfers backups)" &&
		echo "	wait	wait for data mover to finish"
		continue;;
	esac
	auto=:
done
log $DIR CONTROL stopped

