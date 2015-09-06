#!/bin/bash

echo 'POSTGREY_OPTS="--inet=10023 --dbdir=$MAIL_POSTGREY_DATA_DIR"' > /etc/default/postgrey

