#!/bin/bash

#service rsyslog start;

/usr/sbin/rsyslogd -n -c5 &

service postgrey start;
service postfix start;

exec dovecot -F

