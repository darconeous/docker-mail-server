#!/bin/bash

#service rsyslog start;

/usr/sbin/rsyslogd -n -c5 &

dspam --daemon --debug

postgrey --daemon --dbdir=/var/vmail/postgrey

#service postgrey start;
service postfix start;

exec dovecot -F

