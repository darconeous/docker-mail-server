FROM debian:wheezy

# IMPORTANT EXPORTED VOLUMES:
#  * MAIL_CONFIG_DIR   -> /etc/mail-config - User and domain configuration
#  * MAIL_DATA_DIR     -> /data
#  * MAIL_VHOST_DATA_DIR    -> /data/mail
#  * MAIL_DSPAM_DATA_DIR    -> /data/spool/dspam
#  * MAIL_POSTFIX_DATA_DIR  -> /data/spool/postfix

RUN apt-get -y update \
	&& DEBIAN_FRONTEND=noninteractive \
	    apt-get install -y -q --no-install-recommends ssl-cert postfix dovecot-imapd rsyslog dspam dovecot-antispam postfix-pcre dovecot-sieve

# Default Environment Variables
ENV DEBUG=0
ENV MAIL_CONFIG_DIR=/etc/mail-config/
ENV MAIL_DATA_DIR=/data
ENV MAIL_VHOST_DATA_DIR=$MAIL_DATA_DIR/mail
ENV MAIL_DSPAM_DATA_DIR=$MAIL_DATA_DIR/spool/dspam
ENV MAIL_POSTFIX_DATA_DIR=$MAIL_DATA_DIR/spool/postfix

ADD postfix /etc/postfix/
ADD dovecot /etc/dovecot/
ADD dspam /etc/dspam/
ADD boot.d /boot.d/
ADD mail-config $MAIL_CONFIG_DIR

COPY rsyslog.conf /etc/rsyslog.conf
COPY boot.sh /boot.sh
COPY start.sh /start.sh

RUN cat /etc/postfix/master-additional.cf >> /etc/postfix/master.cf \
	&& mkdir -p /var/run/dspam/ /var/run/dovecot/ /var/run/postfix \
	&& mkdir -p ${MAIL_VHOST_DATA_DIR} ${MAIL_DSPAM_DATA_DIR} \
	&& cp -a -r /var/spool/postfix ${MAIL_POSTFIX_DATA_DIR} \
	&& echo "mail.docker.container" > /etc/mailname \
	&& rm -f /etc/dovecot/conf.d/15-mailboxes.conf \
	&& groupadd -g 5000 vmail \
	&& useradd -g vmail -u 5000 vmail -d "${MAIL_VHOST_DATA_DIR}" -m \
	&& chown -R vmail:vmail "${MAIL_DATA_DIR}" \
	&& chmod u+w "${MAIL_DATA_DIR}" \
	&& chmod +x /boot.sh /start.sh

VOLUME ["$MAIL_CONFIG_DIR", "$MAIL_DATA_DIR"]
ENTRYPOINT ["/boot.sh"]
CMD ["/start.sh"]
EXPOSE 25/tcp 143/tcp 587/tcp 38190/tcp
