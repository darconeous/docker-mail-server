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

mkdir -p /var/vmail/postgrey
chown -R postgrey:postgrey /var/vmail/postgrey

mkdir -p /var/vmail/dspam
mkdir -p /var/run/dspam
chown -R dspam:dspam /var/vmail/dspam
chown -R dspam:dspam /var/run/dspam

# Give postfix ownership of its files
chown -R postfix:postfix /etc/postfix

disable_ipv6_prefix="# DISABLE IPv6 START"
disable_ipv6_suffix="# DISABLE IPv6 STOP"

sed "/${disable_ipv6_prefix}/,/${disable_ipv6_suffix}/d" "/etc/postfix/main.cf" -i

# If IPv6 doesn't work, then disable IPv6.
ping6 -c 1 -w 3 google.com 2>/dev/null 1>/dev/null || {
	echo "postfix: IPv6 doesn't work, disabling IPv6" 1>&2
	echo "${disable_ipv6_prefix}" >> /etc/postfix/main.cf 
	echo "inet_protocols = ipv4" >> /etc/postfix/main.cf 
	echo "${disable_ipv6_suffix}" >> /etc/postfix/main.cf 
}

