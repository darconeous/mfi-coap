#!/bin/sh

[ "$1" = "" ] && {
	echo Missing argument
	exit 1
}

gtar -c -C root --owner=0 --group=0 . | ssh $1 "rm bin/smcpd ; tar -x -v -f - -C / ; cfgmtd -w -p /etc/ ; ./rc.poststart"
#gtar cC root | ssh $1 "tar xvC / ; reboot"

