#!/bin/bash

[ "${DEBUG-0}" = "0" ] || set -x

POSTFIX_MAIN_CF=/etc/postfix/main.cf

sed "/@POSTGREY_PORT/d" -i $POSTFIX_MAIN_CF

