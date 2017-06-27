#!/bin/sh

[ "$1" = "" ] && {
	echo Missing argument
	exit 1
}

#gtar -c -C root --owner=0 --group=0 . | ssh $1 "rm bin/smcpd ; tar -x -v -f - -C / ; cfgmtd -w -p /etc/ ; ./rc.poststart"
gtar -c -C root --owner=0 --group=0 . | ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 $1 'cd / ; rm $(cat /var/etc/persistent/mfi-coap-manifest.txt) ; tar -x -v -f - -C / ; killall smcpd ; cd /var/etc/persistent ; ./rc.poststart'
#gtar cC root | ssh $1 "tar xvC / ; reboot"

