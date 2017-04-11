#!/bin/sh

[ "$1" = "" ] && {
	echo Missing argument
	exit 1
}

#./upload-to-device.sh $1 || exit 1

ssh $1 "killall gdbserver ; killall smcpd ; /var/etc/persistent/bin/gdbserver x:2345 /var/etc/persistent/bin/smcpd -d -c /etc/smcpd.conf" &

sleep 5

echo > .gdbinit.temp
echo "file build/root/var/etc/persistent/bin/smcpd" >> .gdbinit.temp
echo "target remote $1:2345" >> .gdbinit.temp

mips32-gcc-docker/run-in-docker.sh -i mips-unknown-linux-uclibc-gdb --command=.gdbinit.temp

rm .gdbinit.temp
