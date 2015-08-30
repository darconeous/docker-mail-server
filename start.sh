#!/bin/bash

service rsyslog start;
service postgrey start;
service postfix start;

exec dovecot -F

