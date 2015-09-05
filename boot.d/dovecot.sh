#!/bin/sh

cp ${MAIL_CONFIG_DIR}/passwd /etc/dovecot/passwd
[ "${DEBUG-0}" = "0" ] && rm -f /etc/dovecot/conf.d/10-logging.conf

MAILDIR=/var/vmail

for address in `cut -d ':' -f 1 < ${MAIL_CONFIG_DIR}/passwd`
do
	username=`echo "${address}" | sed -r 's,(.+)@(.+),\1,'`
	hostname=`echo "${address}" | sed -r 's,(.+)@(.+),\2,'`
	mkdir -p "${MAILDIR}/${hostname}/${username}"
	[ -f "${MAILDIR}/${hostname}/${username}/.dovecot.sieve" ] || cp "/etc/dovecot/dovecot.sieve" "${MAILDIR}/${hostname}/${username}/.dovecot.sieve"
done
