#!/bin/bash

WAIT=10

HERE="$PWD"
BACKUP="$HERE/bin/backup.sh"
MOVER="$HERE/bin/mover.sh"
DIR=bukkit
SERVER=craftbukkit.jar

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
"$BACKUP" && touch .backupped && log 'Backup successful' && [ -x "$MOVER" ] && mover
}

autobackup()
{
[ -f .autobackup ] || return
backup
}

eula()
{
fgrep -x 'eula=false' eula.txt || return
cat eula.txt || return
echo -n "Please type AGREE to agree: "
read agree || return
[ .AGREE = ".$agree" ] || return
sed -i 's/^eula=false$/eula=true/' eula.txt
}

cd "$DIR" || OOPS "WTF? missing $DIR"

log $DIR CONTROL started
autobackup

auto=:
while	
	[ -f .autobackup ] && echo Autobackup is ON
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
		rm -f .backupped
		log STARTING server
		JAVA=java
		JAVAMEM=3G
		JAVARGS=
		[ -x startup-hook.sh ] && . startup-hook.sh
		[ -n "$JAVARGS" ] || JAVARGS="-Xms$JAVAMEM -Xmx$JAVAMEM"
		$JAVA $JAVARGS -jar "$SERVER"
		log TERMINATED with error code $?
		autobackup
		;;
	exit|stop)	break;;
	move)	mover; continue;;
	wait)	echo Waiting; wait; continue;;
	halt)	auto=false; continue;;
	noauto|noautostart)	rm -f .RUNNING; continue;;
	backup)	backup; continue;;
	bkon)	touch .autobackup; continue;;
	bkoff)	rm -f .autobackup; continue;;
	list|info|check)	"$BACKUP" "$cmd";;
	info' '*)		"$BACKUP" "${cmd%% *}" "${cmd#* }";;
	auto|autostart)	touch .RUNNING;;
	eula)	eula;;
	*)	echo "Unknown command.  Possible control-CMDs:"
		echo "	start	(or empty line) to start server"
		echo "	stop	leave control (will be restarted in a minute by cron)"
		echo "	auto	autostart server after stopped"
		echo "	noauto	do not autostart (permanently)"
		echo "	halt	do not autostart (once)"
		[ -x "$BACKUP" ] &&
		echo "	backup	do a backup (if backup script is installed)" &&
		echo "	bkoff	switch autobackup off" &&
		echo "	bkon	switch autobackup on" &&
		echo "	list	list backups" &&
		echo "	info	get info on backup" &&
		echo "	check	check backup archive (warning: this takes very long)" &&
		[ -x "$MOVER" ] &&
		echo "	move	start data mover again (to transfers backups)" &&
		echo "	wait	wait for data mover to finish"
		continue;;
	esac
	auto=:
done
log $DIR CONTROL stopped

