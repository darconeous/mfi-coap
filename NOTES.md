


Trick to verify if connectivity still works:

    ( . /etc/udhcpc/info.ath0 ; /usr/bin/ping -q -c 1 -W 2 "$u_serverid" ) && echo network interface is working fine


