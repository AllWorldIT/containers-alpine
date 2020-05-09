#!/bin/sh

export START_POSTFIX=yes
export POSTFIX_ROOT_ADDRESS=root@localhost
export POSTFIX_MYHOSTNAME=localhost
export POSTFIX_RELAYHOST=127.0.0.1

apk add --no-cache socat

