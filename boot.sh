#!/bin/sh

export MAIL_CONFIG_DIR="${MAIL_CONFIG_DIR-/etc/mail-config}"
export MAIL_DATA_DIR="${MAIL_DATA_DIR-/data}"
export HOST_TLS_CRT="${HOST_TLS_CRT-${MAIL_CONFIG_DIR}/host.crt.pem}"
export HOST_TLS_REQ="${HOST_TLS_REQ-${MAIL_CONFIG_DIR}/host.req.pem}"
export HOST_TLS_KEY="${HOST_TLS_KEY-${MAIL_CONFIG_DIR}/host.key.pem}"

[ "${DEBUG-0}" != "0" ] && set -x

if [ -f ${MAIL_CONFIG_DIR}/hostname ] 
then export HOSTNAME="`head -n 1 ${MAIL_CONFIG_DIR}/hostname`"
elif [ -f ${MAIL_CONFIG_DIR}/domains ] 
then export HOSTNAME="`head -n 1 ${MAIL_CONFIG_DIR}/domains`"
fi

TEMPFILE=/tmp/sedscript

(
	env | grep -e "^MAIL_" -e "^AMAVIS_" -e "^POSTGREY_" -e "^DSPAM_"
) | sed -n -E 's:[\]:\\\\:g;s:/:\\/:g;s:^([a-zA-Z][-_a-zA-Z0-9]*) *= *([^#]*):s/@\1@/\2/g;:p;
' > "$TEMPFILE" || die

for infile in `find /etc -name '*.in'` ;
do
    outfile=$(echo $infile | sed 's/\.in$//')
    echo "    \"$infile\" -> \"$outfile\""
    sed -f "$TEMPFILE" < "$infile" > "$outfile"
done

rm $TEMPFILE

# ----------------------------------------------------------------------

for script in /boot.d/*
do [ -f "$script" -a -x "$script" ] && "$script"
done

exec "$@"
