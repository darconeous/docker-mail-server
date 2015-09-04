#!/bin/sh

export MAIL_CONFIG_DIR="${MAIL_CONFIG_DIR-/etc/mail-config}"
export HOST_TLS_CRT="${HOST_TLS_CRT-${MAIL_CONFIG_DIR}/host.crt.pem}"
export HOST_TLS_REQ="${HOST_TLS_REQ-${MAIL_CONFIG_DIR}/host.req.pem}"
export HOST_TLS_KEY="${HOST_TLS_KEY-${MAIL_CONFIG_DIR}/host.key.pem}"

[ "${DEBUG-0}" != "0" ] && set -x

if [ -f ${MAIL_CONFIG_DIR}/hostname ] 
then export HOSTNAME="`head -n 1 ${MAIL_CONFIG_DIR}/hostname`"
elif [ -f ${MAIL_CONFIG_DIR}/domains ] 
then export HOSTNAME="`head -n 1 ${MAIL_CONFIG_DIR}/domains`"
fi

# ----------------------------------------------------------------------

for script in /boot.d/*
do [ -f "$script" -a -x "$script" ] && "$script"
done

exec "$@"
