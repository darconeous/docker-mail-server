#!/bin/bash

die () {
	cleanup
	echo "FATAL: ${1-Unknown}"
	exit 1
}

cleanup () {
	echo Cleaning up...
	service postfix stop
	service dspam stop
	service dovecot stop
	service rsyslog stop
	killall master dovecot dspam rsyslogd 2> /dev/null
	killall -9 master dovecot dspam rsyslogd 2> /dev/null
}

check_everything() {
	killall -s 0 dovecot || die "Dovecot no longer running"
	killall -s 0 master || die "Postfix no longer running"
	killall -s 0 dspam || die "dspam no longer running"
	killall -s 0 rsyslogd || die "rsyslogd no longer running"
	true
}

#trap cleanup EXIT

/usr/sbin/rsyslogd -n -c5 & disown

dspam --daemon

service postfix start || die "Unable to start postfix service"

service dovecot start || die "Unable to start dovecot service"

check_everything

while sleep 60
do check_everything
done

cleanup

