#!/bin/bash

[ "${DEBUG-0}" = "0" ] || set -x

POSTFIX_MAIN_CF=/etc/postfix/main.cf

if grep -q @POSTGREY_PORT "$POSTFIX_MAIN_CF"
then echo "Postgrey not linked, will not use greylisting"
else echo "Postgrey linked, greylisting enabled"
fi

# Remove the useless postgrey line from the configuration
sed "/@POSTGREY_PORT/d" -i "$POSTFIX_MAIN_CF"

