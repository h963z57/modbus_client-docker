#!/bin/bash

# ========= Check env availability ===============
if [[ -z "${MODBUS_DEVICES}" && "${MODBUS_EMAIL_ADMIN}" && "${MODBUS_CREDENTIAL}" ]]; then
  echo "No one or more env"
  exit 0
else
  echo "All env is exists"
fi

# ================ Functions =====================
generate_configs () {
    MODBUS_KEY=${MODBUS_DEVICE%:*} 
    MODBUS_VALUE=${MODBUS_DEVICE#*:}
    echo "====================================================================="
    echo "Connect to modbus devices and setup selfheal system for ${MODBUS_KEY}"
    echo "Connect to ${MODBUS_KEY} create link /dev/ttyRS485-${MODBUS_VALUE}"
    nohup socat -d -d -d -x PTY,raw,b9600,parenb=0,cstopb=2,cs8,link=/dev/ttyRS485-$MODBUS_VALUE tcp:$MODBUS_KEY:502 > /var/log/modbus/socat.log 2>& 1& < /dev/null &

    echo "Create run file for $MODBUS_VALUE"
    echo "nohup socat -d -d -d -x PTY,raw,b9600,parenb=0,cstopb=2,cs8,link=/dev/ttyRS485-$MODBUS_VALUE tcp:$MODBUS_KEY:502 > /var/log/modbus/socat.log 2>& 1& < /dev/null &" >> /run/modbus/$MODBUS_VALUE.sh

    echo "Cleanup..."
    unset MODBUS_DEVICE
    unset MODBUS_KEY
    unset MODBUS_VALUE
}

create_users () {
    MODBUS_KEY=${MODBUS_CREDENTIAL%:*} 
    MODBUS_VALUE=${MODBUS_CREDENTIAL#*:}
    echo "Create user $MODBUS_KEY"
    adduser --disabled-password --gecos "" $MODBUS_KEY

    # echo "===============================" #DEBUG
    # echo $MODBUS_CREDENTIAL                #DEBUG
    # echo $MODBUS_KEY                       #DEBUG
    # echo $MODBUS_VALUE                     #DEBUG
    # echo "===============================" #DEBUG

    echo "Enable auth by ssh-key"
    mkdir -p /home/$MODBUS_KEY/.ssh/
    echo $MODBUS_VALUE >> /home/$MODBUS_KEY/.ssh/authorized_keys

    echo "Add user $MODBUS_KEY to sudo group"
    echo "$MODBUS_KEY ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-$MODBUS_KEY-user
    
    echo "Cleanup..."
    unset MODBUS_CREDENTIAL
    unset MODBUS_KEY
    unset MODBUS_VALUE
}


# =============== Initialisatin ====================
for MODBUS_DEVICE in $MODBUS_DEVICES
    do
        generate_configs
    done

# ================ User create =====================
create_users

# ============== Enable selfheal ===================
echo "MODBUS_DEVICES='$MODBUS_DEVICES'" >> /etc/environment && source /etc/environment

# =============== Start serveces ===================
echo "Start crontab"
service cron start
echo "Start ssh"
service ssh start && bash


# =============== Enable logging ===================
echo "Log start..."
tail -f /var/log/modbus/socat.log -f /var/log/modbus/modbus_client.log -f /var/log/modbus/selfhealling.log