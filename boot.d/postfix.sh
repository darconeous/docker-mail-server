#!/bin/sh

[ "${DEBUG-0}" = "0" ] || set -x

# Copy over the dist chroot to ensure that it is up to date.
mkdir -p "${MAIL_POSTFIX_DATA_DIR}"
tar cC /var/spool/postfix . | tar xC "${MAIL_POSTFIX_DATA_DIR}"

mkdir /etc/postfix/tmp
(
	awk < ${MAIL_CONFIG_DIR}/aliases '{ print $2 }'
	cut -d ':' -f 1 < ${MAIL_CONFIG_DIR}/passwd
) | sort -u > /etc/postfix/tmp/virtual-receivers
sed -r 's,(.+)@(.+),\2/\1/,' /etc/postfix/tmp/virtual-receivers > /etc/postfix/tmp/virtual-receiver-folders
paste /etc/postfix/tmp/virtual-receivers /etc/postfix/tmp/virtual-receiver-folders > /etc/postfix/virtual-mailbox-maps

usermod -m -d "${MAIL_POSTFIX_DATA_DIR}" postfix
usermod -m -d "${MAIL_DSPAM_DATA_DIR}" dspam
usermod -m -d "${MAIL_POSTGREY_DATA_DIR}" postgrey

cp ${MAIL_CONFIG_DIR}/aliases /etc/postfix/virtual-aliases
cp ${MAIL_CONFIG_DIR}/domains /etc/postfix/virtual-domains

postmap /etc/postfix/virtual-aliases
postmap /etc/postfix/virtual-mailbox-maps

chown -R vmail:vmail "${MAIL_VHOST_DATA_DIR}"

mkdir -p "${MAIL_POSTGREY_DATA_DIR}"
chown -R postgrey:postgrey "${MAIL_POSTGREY_DATA_DIR}"

mkdir -p "${MAIL_DSPAM_DATA_DIR}"
chown -R dspam:dspam "${MAIL_DSPAM_DATA_DIR}"

mkdir -p /var/run/dspam
chown -R dspam:dspam /var/run/dspam

# Give postfix ownership of its files
chown -R postfix:postfix /etc/postfix

scripted_conf_prefix="# SCRIPTED CONF START"
scripted_conf_suffix="# SCRIPTED CONF STOP"

sed "/${scripted_conf_prefix}/,/${scripted_conf_suffix}/d" "/etc/postfix/main.cf" -i
echo "${scripted_conf_prefix}" >> /etc/postfix/main.cf 

# If IPv6 doesn't work, then disable IPv6.
ping6 -c 1 -w 3 google.com 2>/dev/null 1>/dev/null || {
	echo "postfix: IPv6 doesn't work, disabling IPv6" 1>&2
	echo "inet_protocols = ipv4" >> /etc/postfix/main.cf 
}
echo "queue_directory = ${MAIL_POSTFIX_DATA_DIR}" >> /etc/postfix/main.cf
echo "${scripted_conf_suffix}" >> /etc/postfix/main.cf 

