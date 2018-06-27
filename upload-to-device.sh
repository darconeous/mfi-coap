#!/bin/sh

[ "$1" = "" ] && {
	echo Missing argument
	exit 1
}
set -x
SSH="ssh"
SSH="ssh -oKexAlgorithms=+diffie-hellman-group1-sha1"

#gtar -c -C root --owner=0 --group=0 . | $SSH $1 "rm bin/smcpd ; tar -x -v -f - -C / ; cfgmtd -w -p /etc/ ; ./rc.poststart"
gtar -c -C root --owner=0 --group=0 . | $SSH $1 'cd / ; rm $(cat /var/etc/persistent/mfi-coap-manifest.txt) ; tar -x -v -f - -C / ; killall smcpd ; cd /var/etc/persistent ; ./rc.poststart'
#gtar cC root | $SSH $1 "tar xvC / ; reboot"

