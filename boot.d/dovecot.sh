#!/bin/sh

[ "${DEBUG-0}" = "0" ] || set -x

cp ${MAIL_CONFIG_DIR}/passwd /etc/dovecot/passwd
[ "${DEBUG-0}" = "0" ] && rm -f /etc/dovecot/conf.d/10-logging.conf

for address in `cut -d ':' -f 1 < ${MAIL_CONFIG_DIR}/passwd`
do
	username=`echo "${address}" | sed -r 's,(.+)@(.+),\1,'`
	hostname=`echo "${address}" | sed -r 's,(.+)@(.+),\2,'`
	mkdir -p "${MAIL_VHOST_DATA_DIR}/${hostname}/${username}"
	[ -f "${MAIL_VHOST_DATA_DIR}/${hostname}/${username}/.dovecot.sieve" ] || cp "/etc/dovecot/dovecot.sieve" "${MAIL_VHOST_DATA_DIR}/${hostname}/${username}/.dovecot.sieve"
done
