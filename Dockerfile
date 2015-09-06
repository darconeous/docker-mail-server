FROM debian:wheezy

# IMPORTANT EXPORTED VOLUMES:
#  * MAIL_CONFIG_DIR   -> /etc/mail-config - User and domain configuration
#  * MAIL_DATA_DIR     -> /data
#  * MAIL_VHOST_DATA_DIR    -> /data/vhost
#  * MAIL_DSPAM_DATA_DIR    -> /data/dspam
#  * MAIL_POSTGREY_DATA_DIR -> /data/postgrey
#  * MAIL_POSTFIX_DATA_DIR  -> /data/postfix

RUN apt-get -y update \
	&& DEBIAN_FRONTEND=noninteractive \
	    apt-get install -y -q --no-install-recommends ssl-cert postfix postgrey dovecot-imapd rsyslog dspam dovecot-antispam postfix-pcre dovecot-sieve

# Default Environment Variables
ENV DEBUG=0
ENV MAIL_CONFIG_DIR=/etc/mail-config/
ENV MAIL_DATA_DIR=/data
ENV MAIL_VHOST_DATA_DIR=$MAIL_DATA_DIR/vhost
ENV MAIL_DSPAM_DATA_DIR=$MAIL_DATA_DIR/dspam
ENV MAIL_POSTGREY_DATA_DIR=$MAIL_DATA_DIR/postgrey
ENV MAIL_POSTFIX_DATA_DIR=$MAIL_DATA_DIR/postfix

# postfix configuration
RUN echo "mail.docker.container" > /etc/mailname
ADD postfix /etc/postfix/
ADD dovecot /etc/dovecot/
ADD dspam /etc/dspam/
ADD mail-config $MAIL_CONFIG_DIR
RUN cat /etc/postfix/master-additional.cf >> /etc/postfix/master.cf

RUN mkdir -p /var/run/dspam/ /var/run/dovecot/ /var/run/postfix

RUN mkdir -p ${MAIL_VHOST_DATA_DIR} ${MAIL_DSPAM_DATA_DIR} ${MAIL_POSTGREY_DATA_DIR}

RUN cp -a -r /var/spool/postfix ${MAIL_POSTGREY_DATA_DIR}

ADD boot.d /boot.d/

# add user vmail who own all mail folders
RUN groupadd -g 5000 vmail
RUN useradd -g vmail -u 5000 vmail -d ${MAIL_VHOST_DATA_DIR} -m
RUN chown -R vmail:vmail ${MAIL_DATA_DIR}
RUN chmod u+w ${MAIL_DATA_DIR}

# Mail Config State
VOLUME ["$MAIL_CONFIG_DIR"]

# Mailbox State
VOLUME ["$MAIL_DATA_DIR"]

COPY rsyslog.conf /etc/rsyslog.conf

COPY boot.sh /boot.sh
RUN chmod +x /boot.sh
ENTRYPOINT ["/boot.sh"]

COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

EXPOSE 25/tcp 143/tcp 587/tcp 38190/tcp
