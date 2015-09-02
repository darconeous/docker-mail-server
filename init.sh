#!/bin/sh

HOST_TLS_CRT="${HOST_TLS_CRT-/etc/mail-config/host.crt.pem}"
HOST_TLS_REQ="${HOST_TLS_REQ-/etc/mail-config/host.req.pem}"
HOST_TLS_KEY="${HOST_TLS_KEY-/etc/mail-config/host.key.pem}"

# ----------------------------------------------------------------------

if [ "${DEBUG-0}" = "0" ]
then rm -f /etc/dovecot/conf.d/10-logging.conf
else set -x
fi

# ----------------------------------------------------------------------

mkdir /etc/postfix/tmp
(
	awk < /etc/mail-config/aliases '{ print $2 }'
	cut -d ':' -f 1 < /etc/mail-config/passwd
) | sort -u > /etc/postfix/tmp/virtual-receivers
sed -r 's,(.+)@(.+),\2/\1/,' /etc/postfix/tmp/virtual-receivers > /etc/postfix/tmp/virtual-receiver-folders
paste /etc/postfix/tmp/virtual-receivers /etc/postfix/tmp/virtual-receiver-folders > /etc/postfix/virtual-mailbox-maps
postmap /etc/mail-config/aliases
postmap /etc/postfix/virtual-mailbox-maps

chown -R vmail:vmail /var/vmail

# ----------------------------------------------------------------------

if [ -f /etc/mail-config/hostname ] 
then HOSTNAME=`head -n 1 /etc/mail-config/hostname`
elif [ -f /etc/mail-config/domains ] 
then HOSTNAME=`head -n 1 /etc/mail-config/domains`
fi

# ----------------------------------------------------------------------

HOST_TLS_OPENSSL_CONF=/tmp/openssl.cnf
cat > "${HOST_TLS_OPENSSL_CONF}" <<EOF
[ req ]
x509_extensions        = v3_ca
req_extensions         = v3_req
default_md             = sha256
prompt                 = no
utf8                   = yes
distinguished_name     = req_distinguished_name

[ req_distinguished_name ]
commonName             = ${HOSTNAME}

[ v3_req ]
basicConstraints       = CA:false
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints       = CA:false
subjectAltName         = @alt_names

[ alt_names ]
DNS.1                  = ${HOSTNAME}
EOF

#domain_index=2
#for domain in `cat /etc/mail-config/domains`
#do
#	echo "DNS.$((domain_index)) = $domain" >> "${HOST_TLS_OPENSSL_CONF}"
#	domain_index=$((domain_index+1))
#done
#unset domain_index

[ "${DEBUG-0}" = "0" ] || cat "${HOST_TLS_OPENSSL_CONF}"

# ----------------------------------------------------------------------

if [ '!' -f "${HOST_TLS_KEY}" ]
then openssl genrsa -out "${HOST_TLS_KEY}" -f4 2048 -config "${HOST_TLS_OPENSSL_CONF}"
fi

# Always regenerate the request, in case it is needed.
openssl req -new -key "${HOST_TLS_KEY}" -out "${HOST_TLS_REQ}" -extensions v3_ca -config "${HOST_TLS_OPENSSL_CONF}"

# Rebuild the self-signed X509 certificate only if it is missing.
# This certificate is intended to be replaced by the user with a real signed certificate.
if [ '!' -f "${HOST_TLS_CRT}" ]
then
	openssl req -x509 -nodes -days 3650 -key "${HOST_TLS_KEY}" -out "${HOST_TLS_CRT}" -extensions v3_ca -config "${HOST_TLS_OPENSSL_CONF}" < "${HOST_TLS_REQ}"
	openssl x509 -in "${HOST_TLS_CRT}" -noout -text
fi

openssl x509 -in "${HOST_TLS_CRT}" -noout -text

cp "${HOST_TLS_CRT}" /etc/ssl/certs/ssl-cert-snakeoil.pem
cp "${HOST_TLS_KEY}" /etc/ssl/private/ssl-cert-snakeoil.key

# ----------------------------------------------------------------------

exec "$@"
