FROM debian:wheezy

# IMPORTANT EXPORTED VOLUMES:
#  * /etc/mail-config - User and domain configuration
#  * /var/vmail - mail storage location

RUN apt-get -y update \
	&& DEBIAN_FRONTEND=noninteractive \
	    apt-get install -y -q --no-install-recommends ssl-cert postfix postgrey dovecot-imapd rsyslog

# Default Environment Variables
ENV DEBUG=0
ENV MAIL_CONFIG_DIR=/etc/mail-config/

# postfix configuration
RUN echo "mail.docker.container" > /etc/mailname
ADD postfix /etc/postfix/
ADD dovecot /etc/dovecot/
ADD mail-config $MAIL_CONFIG_DIR
RUN cat /etc/postfix/master-additional.cf >> /etc/postfix/master.cf

ADD boot.d /boot.d/

# add user vmail who own all mail folders
RUN groupadd -g 5000 vmail
RUN useradd -g vmail -u 5000 vmail -d /var/vmail -m
RUN chown -R vmail:vmail /var/vmail
RUN chmod u+w /var/vmail

VOLUME ["$MAIL_CONFIG_DIR"]
VOLUME ["/var/vmail"]

COPY rsyslog.conf /etc/rsyslog.conf

COPY boot.sh /boot.sh
RUN chmod +x /boot.sh
ENTRYPOINT ["/boot.sh"]

COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]

EXPOSE 25/tcp 143/tcp 587/tcp
