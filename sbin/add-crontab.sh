#!/bin/bash
#
# Add something to crontab, do not touch unknown entries
#
# Note that this adds something to STDIN of the CMD, as crontabs do not allow to place magics in comments.  If you do not want this, wrap.

MAGIC="%%% automatically added, do not edit"

OOPS()
{
echo "OOPS: $*" >&2
exit 1
}

[ 3 = $# ] || OOPS "Usage: `basename "$0"` CRON-fields CMDLINE Initial-STDIN"

LINE="$1 $2 %$3$MAGIC"

crontab -l | fgrep -qx "$LINE" && exit	# ok, installed

echo "new/updated crontab entry: $LINE" >&2

{
crontab -l | sed "/$MAGIC\$/d"
echo "$LINE"
} |
crontab

