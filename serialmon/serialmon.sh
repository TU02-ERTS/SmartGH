#!/bin/bash

DELAY=1.8
MAX_HISTORY=3600

GPIO=/usr/local/bin/gpio

SERIALMON_PATH=`cd $(dirname $0) ; pwd -P`
SERIALMON_OUT_PATH="/var/log/serialmon"

THRESHOLDS_PATH="/var/opt/serialmon/thresholds"

while :; do
    readings=`awk -f "$SERIALMON_PATH/read_serial_ama0.awk" /dev/ttyAMA0`
    echo -e `date +"%s"` "\t$readings" >> "$SERIALMON_OUT_PATH/serialmon.dat"
    tail -n $MAX_HISTORY "$SERIALMON_OUT_PATH/serialmon.dat" > "$SERIALMON_OUT_PATH/temp.dat"
    mv "$SERIALMON_OUT_PATH/temp.dat" "$SERIALMON_OUT_PATH/serialmon.dat"

    T0=`echo -e "$readings" | cut -f 1`
    L0=`echo -e "$readings" | cut -f 2`
    RH0=`echo -e "$readings" | cut -f 3`
    T1=`echo -e "$readings" | cut -f 4`
    L1=`echo -e "$readings" | cut -f 5`
    RH1=`echo -e "$readings" | cut -f 6`

    threshL=`cat $THRESHOLDS_PATH/L`
    threshT=`cat $THRESHOLDS_PATH/T`
    threshRH=`cat $THRESHOLDS_PATH/RH`

    let "avgT=($T0+$T1)/2"
    let "avgL=($L0+$L1)/2"
    let "avgRH=($RH0+$RH1)/2"

    if [ "$avgT" -gt "$threshT" ]; then
        $GPIO write 3 1
    else
        $GPIO write 3 0
    fi

    if [ "$avgL" -lt "$threshL" ]; then
        $GPIO write 4 1
    else
        $GPIO write 4 0
    fi

    if [ "$avgRH" -lt "$threshRH" ]; then
        $GPIO write 3 1
    else
        $GPIO write 3 0
    fi

    sleep $DELAY
done
