#!/bin/sh

set +x

mkdir /etc/postfix/tmp
awk < /etc/mail-config/aliases '{ print $2 }' > /etc/postfix/tmp/virtual-receivers
sed -r 's,(.+)@(.+),\2/\1/,' /etc/postfix/tmp/virtual-receivers > /etc/postfix/tmp/virtual-receiver-folders
paste /etc/postfix/tmp/virtual-receivers /etc/postfix/tmp/virtual-receiver-folders > /etc/postfix/virtual-mailbox-maps

postmap /etc/mail-config/aliases
postmap /etc/postfix/virtual-mailbox-maps

[ "${DEBUG-0}" = "0" ] && rm -f /etc/dovecot/conf.d/10-logging.conf

chown -R vmail:vmail /var/vmail

exec "$@"
