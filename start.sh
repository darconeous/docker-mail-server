#!/bin/bash

cleanup () {
	echo Cleaning up...
	service postfix stop
	service postgrey stop
	service dspam stop
}

trap cleanup EXIT SIGINT SIGTERM

die () {
	echo "FATAL: ${1-Unknown}"
	exit 1
}

#service rsyslog start;

/usr/sbin/rsyslogd -n -c5 &

dspam --daemon --debug


service postgrey start || die "Unable to start postgrey"

service postfix start || die "Unable to start postfix service"

dovecot -F

