#!/bin/bash
echo "Start check and restore connection"
for MODBUS_DEVICE in $MODBUS_DEVICES
    do
        MODBUS_KEY=${MODBUS_DEVICE%:*} 
        MODBUS_VALUE=${MODBUS_DEVICE#*:}
        if [ -e "/dev/ttyRS485-$MODBUS_VALUE" ]; then
            echo "Device with id $MODBUS_VALUE connected"
            else
                echo "Restore connection with device with id ${MODBUS_VALUE}"
                sh /run/modbus/${MODBUS_VALUE}.sh
        fi
    done