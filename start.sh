#!/bin/bash

cleanup () {
	echo Cleaning up...
	service postfix stop
	service dspam stop
}

trap cleanup EXIT

die () {
	echo "FATAL: ${1-Unknown}"
	exit 1
}

#service rsyslog start;

/usr/sbin/rsyslogd -n -c5 &

dspam --daemon --debug

service postfix start || die "Unable to start postfix service"

dovecot -F

