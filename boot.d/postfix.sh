#!/bin/sh


mkdir /etc/postfix/tmp
(
	awk < ${MAIL_CONFIG_DIR}/aliases '{ print $2 }'
	cut -d ':' -f 1 < ${MAIL_CONFIG_DIR}/passwd
) | sort -u > /etc/postfix/tmp/virtual-receivers
sed -r 's,(.+)@(.+),\2/\1/,' /etc/postfix/tmp/virtual-receivers > /etc/postfix/tmp/virtual-receiver-folders
paste /etc/postfix/tmp/virtual-receivers /etc/postfix/tmp/virtual-receiver-folders > /etc/postfix/virtual-mailbox-maps

cp ${MAIL_CONFIG_DIR}/aliases /etc/postfix/virtual-aliases
cp ${MAIL_CONFIG_DIR}/domains /etc/postfix/virtual-domains

postmap /etc/postfix/virtual-aliases
postmap /etc/postfix/virtual-mailbox-maps

chown -R vmail:vmail /var/vmail

# Give postfix ownership of its files
chown -R postfix:postfix /etc/postfix

