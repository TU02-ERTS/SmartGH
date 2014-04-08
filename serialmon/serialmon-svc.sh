#!/bin/bash

RESTART_DELAY=0.5
SERIALMON_PATH=`cd $(dirname $0) ; pwd -P`
SERIALMON_OUT_PATH="/var/log/serialmon"

rm -rf "$SERIALMON_OUT_PATH"
mkdir -p "$SERIALMON_OUT_PATH"
exec > /dev/null 2> /dev/null

function on_exit {
    kill 0
    mv "$SERIALMON_OUT_PATH/temp.dat" "$SERIALMON_OUT_PATH/serialmon.dat"
    log "  [<] 'serialmon' has exited."
    log "[-] 'serialmon-service' has terminated."
}
trap on_exit EXIT

function log {
    echo `date` "$1"
}

log "[+] 'serialmon-service' has started."
log "  [>] 'serialmon' has started."
until "$SERIALMON_PATH/serialmon.sh"; do
    log "  [<] 'serialmon' has exited."
    log "  [>] 'serialmon' has started."
    sleep $RESTART_DELAY
done
