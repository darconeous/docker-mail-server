#!/bin/bash
#echo 'Running opendkim boot script'

[ "${DEBUG-0}" = "0" ] || set -x

POSTFIX_MAIN_CF=/etc/postfix/main.cf
#POSTFIX_MASTER_CF=/etc/postfix/master.cf

env_dump=$(printenv)

OPENDKIM_CONFIG_HEADER="# opendkim - dockermail - start"
OPENDKIM_CONFIG_FOOTER="# opendkim - dockermail - end"


OPENDKIM_PORT_TCP_ADDR="${OPENDKIM_PORT_8891_TCP_ADDR-opendkim}"
OPENDKIM_PORT_TCP_PORT="${OPENDKIM_PORT_8891_TCP_PORT-8891}"

function remove_opendkim () {
  # main.cf
  if grep -q "$OPENDKIM_CONFIG_HEADER" "$POSTFIX_MAIN_CF"; then
    sed "/$OPENDKIM_CONFIG_HEADER/,/$OPENDKIM_CONFIG_FOOTER/d" "$POSTFIX_MAIN_CF" -i
  fi
}

function add_opendkim () {
  # main.cf
  if ! grep -q "$OPENDKIM_CONFIG_HEADER" "$POSTFIX_MAIN_CF"; then
    echo "$OPENDKIM_CONFIG_HEADER" >> "$POSTFIX_MAIN_CF"
	echo "smtpd_milters           = inet:${OPENDKIM_PORT_TCP_ADDR}:${OPENDKIM_PORT_TCP_PORT}" >> "$POSTFIX_MAIN_CF"
	echo 'non_smtpd_milters       = $smtpd_milters' >> "$POSTFIX_MAIN_CF"
	echo 'milter_default_action   = accept' >> "$POSTFIX_MAIN_CF"
    echo "$OPENDKIM_CONFIG_FOOTER" >> "$POSTFIX_MAIN_CF"
  else
    echo "Warning: $POSTFIX_MAIN_CF already contains opendkim configuration, skipping"
  fi
}

if [[ $env_dump =~ ^(.+OPENDKIM)= ]] ; then
  if [ ! -z "${BASH_REMATCH[1]}" ]; then
    echo "OPENDKIM on ${OPENDKIM_PORT_TCP_ADDR}:${OPENDKIM_PORT_TCP_PORT}"
    add_opendkim
  fi
else
  echo "Cant find OPENDKIM env, OPENDKIM disabled"
  remove_opendkim
fi

#echo 'Finished opendkim boot script'
