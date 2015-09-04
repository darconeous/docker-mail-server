#!/bin/sh

cp ${MAIL_CONFIG_DIR}/passwd /etc/dovecot/passwd
[ "${DEBUG-0}" = "0" ] && rm -f /etc/dovecot/conf.d/10-logging.conf

